{ pkgs, lib, ... }:
let
  maxBytes = 10 * 1024 * 1024;
  keep = 3;

  # launchd keeps a job's log open while it runs, so newsyslog's rename would
  # leave it writing to the old file; compress a copy and truncate in place
  # instead (launchd appends, so writes carry on from the start)
  rotate =
    name: logs:
    pkgs.writeShellScript "log-rotate-${name}" ''
      set -u
      PATH=${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.gzip
        ]
      }

      for log in ${logs}; do
        [ -f "$log" ] && [ "$(stat -c %s "$log")" -gt ${toString maxBytes} ] || continue
        for i in $(seq ${toString (keep - 1)} -1 1); do
          [ -e "$log.$i.gz" ] && mv "$log.$i.gz" "$log.$((i + 1)).gz"
        done
        gzip -c "$log" > "$log.1.gz" && truncate -s 0 "$log"
        echo "$(date '+%F %T') rotated $log"
      done
    '';

  job = name: dir: logs: {
    ProgramArguments = lib.ted.waitForNix [ "${rotate name logs}" ];
    StartInterval = 3600;
    StandardErrorPath = "${dir}/log-rotate.log";
    StandardOutPath = "${dir}/log-rotate.log";
  };
in
{
  launchd.user.agents.log-rotate.serviceConfig =
    job "user" "/Users/ted/Library/Logs"
      "/Users/ted/Library/Logs/*.log";

  # Only the daemons' own logs, not the rest of /var/log
  launchd.daemons.log-rotate.serviceConfig =
    job "system" "/var/log"
      "/var/log/wg-quick-*.log /var/log/ersatztv-pf.log /var/log/nas-media.log /var/log/log-rotate.log";
}
