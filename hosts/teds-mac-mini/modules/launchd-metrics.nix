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

      # A crash loop can still look running (and pass its probe) between restarts,
      # so count runs; periodic jobs rerun by design, so mark the ones kept alive
      target=${if domain == "user" then "gui/$(/usr/bin/id -u)" else "system"}
      for name in $(/bin/launchctl list | /usr/bin/awk '$3 ~ /^org\.nixos\./ { print $3 }'); do
        /bin/launchctl print "$target/$name" 2>/dev/null | /usr/bin/awk -v n="$name" -v d=${domain} '
          /^\truns = / { runs = $3 }
          /^\tproperties = .*keepalive/ { keepalive = 1 }
          END { if (runs != "") printf "launchd_job_runs_total{name=\"%s\",domain=\"%s\",keepalive=\"%d\"} %s\n", n, d, keepalive, runs }
        ' >> "$tmp"
      done

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
