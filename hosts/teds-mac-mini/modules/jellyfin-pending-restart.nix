{ pkgs, lib, ... }:
let
  dir = "/Users/ted/.local/share/node-exporter/textfile";
  tokenFile = "/Users/ted/.config/jelly-metrics/token";

  # Plugin updates (and installs) only load after a restart, which Jellyfin
  # leaves to an admin, so export the flag for the JellyfinRestartPending alert
  write = pkgs.writeShellScript "jellyfin-pending-restart" ''
    set -euo pipefail
    mkdir -p ${dir}
    pending=$(${pkgs.curl}/bin/curl -fsS --max-time 10 \
      -H "Authorization: MediaBrowser Token=$(< ${tokenFile})" \
      http://127.0.0.1:8096/System/Info |
      ${pkgs.jq}/bin/jq -r 'if .HasPendingRestart then 1 else 0 end')
    tmp=$(mktemp ${dir}/.jellyfin.XXXXXX)
    echo "jellyfin_pending_restart $pending" > "$tmp"
    chmod 644 "$tmp"
    mv "$tmp" ${dir}/jellyfin.prom
  '';
in
{
  launchd.user.agents.jellyfin-pending-restart.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [ "${write}" ];
    RunAtLoad = true;
    StartInterval = 300;
  };
}
