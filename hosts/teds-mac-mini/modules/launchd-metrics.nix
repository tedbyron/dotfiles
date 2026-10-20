{ pkgs, ... }:
let
  dir = "/Users/ted/.local/share/node-exporter/textfile";

  write =
    domain:
    pkgs.writeShellScript "launchd-metrics-${domain}" ''
      set -eu
      mkdir -p ${dir}
      tmp=$(mktemp ${dir}/.launchd-${domain}.XXXXXX)
      /bin/launchctl list | /usr/bin/awk -v d=${domain} '
        $3 ~ /^org\.nixos\./ {
          exit_status[$3] = $2
          running[$3] = ($1 != "-")
        }
        END {
          for (n in exit_status) printf "launchd_job_last_exit_status{name=\"%s\",domain=\"%s\"} %s\n", n, d, exit_status[n]
          for (n in running) printf "launchd_job_running{name=\"%s\",domain=\"%s\"} %d\n", n, d, running[n]
        }
      ' > "$tmp"
      chmod 644 "$tmp"
      mv "$tmp" ${dir}/launchd-${domain}.prom
    '';

  job = domain: {
    ProgramArguments = [ "${write domain}" ];
    RunAtLoad = true;
    StartInterval = 60;
  };
in
{
  launchd.user.agents.launchd-metrics.serviceConfig = job "user";
  launchd.daemons.launchd-metrics.serviceConfig = job "system";
}
