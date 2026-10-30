{ pkgs, lib, ... }:
let
  dir = "/Users/ted/.local/share/node-exporter/textfile";
  db = "/Users/ted/.local/share/cleanuparr/events.db";

  # Cleanuparr's "action required" events (a removed download that keeps coming
  # back, a replacement search it skipped) stay unresolved until marked resolved
  # on its Events page, so export the count for the CleanuparrActionRequired alert
  write = pkgs.writeShellScript "cleanuparr-events" ''
    set -euo pipefail
    mkdir -p ${dir}
    tmp=$(mktemp ${dir}/.cleanuparr.XXXXXX)
    ${pkgs.sqlite}/bin/sqlite3 -readonly -separator $'\t' ${db} "
      select severity, type, coalesce(instance_url, '''), count(*)
      from manual_events
      where is_resolved = 0 and is_dry_run = 0
      group by 1, 2, 3
    " | ${pkgs.gawk}/bin/awk -F '\t' '{
      printf "cleanuparr_unresolved_events{severity=\"%s\",type=\"%s\",instance=\"%s\"} %s\n", $1, $2, $3, $4
    }' > "$tmp"
    chmod 644 "$tmp"
    mv "$tmp" ${dir}/cleanuparr.prom
  '';
in
{
  launchd.user.agents.cleanuparr-events.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [ "${write}" ];
    RunAtLoad = true;
    StartInterval = 300;
  };
}
