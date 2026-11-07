{ pkgs, lib, ... }:
let
  promData = "/Users/ted/.local/share/prometheus";
  log = "/Users/ted/Library/Logs/prometheus.log";

  keep = metrics: [
    {
      source_labels = [ "__name__" ];
      regex = "(${builtins.concatStringsSep "|" metrics})";
      action = "keep";
    }
  ];

  yaml = pkgs.formats.yaml { };

  services = [
    {
      name = "Jellyfin";
      url = "http://127.0.0.1:8096/health";
    }
    {
      name = "Seerr";
      url = "http://127.0.0.1:5055/api/v1/status";
    }
    {
      name = "Sonarr";
      url = "http://127.0.0.1:8989/ping";
    }
    {
      name = "Sonarr 4K";
      url = "http://127.0.0.1:8990/ping";
    }
    {
      name = "Radarr";
      url = "http://127.0.0.1:7878/ping";
    }
    {
      name = "Radarr 4K";
      url = "http://127.0.0.1:7879/ping";
    }
    {
      name = "Prowlarr";
      url = "http://127.0.0.1:9696/ping";
    }
    {
      name = "Cleanuparr";
      url = "http://127.0.0.1:11011/health";
    }
    {
      name = "Bazarr";
      url = "http://127.0.0.1:6767/";
    }
    {
      name = "Bazarr 4K";
      url = "http://127.0.0.1:6768/";
    }
    {
      name = "qBittorrent";
      url = "http://127.0.0.1:8080/";
    }
    {
      name = "ErsatzTV";
      url = "http://127.0.0.1:8409/";
    }
    {
      name = "tedbot";
      url = "http://127.0.0.1:5056/health";
    }
    {
      name = "FlareSolverr";
      url = "http://127.0.0.1:8191/";
    }
    {
      name = "Grafana";
      url = "http://127.0.0.1:3000/api/health";
    }
  ];

  # Names services in alert text. Done in the template rather than as a target
  # label, which would start new probe_success series and split the status
  # page's 30-day uptime
  serviceName = lib.concatMapStrings (
    s: ''{{ if eq $labels.instance "${s.url}" }}${s.name}{{ end }}''
  ) services;
  # https://stream.ted.ooo/health -> stream.ted.ooo
  host = ''{{ reReplaceAll "^https?://([^/]+).*" "$1" $labels.instance }}'';

  probe = job: targets: {
    job_name = job;
    metrics_path = "/probe";
    params.module = [ "http_2xx" ];
    static_configs = [ { inherit targets; } ];
    relabel_configs = [
      {
        source_labels = [ "__address__" ];
        target_label = "__param_target";
      }
      {
        source_labels = [ "__param_target" ];
        target_label = "instance";
      }
      {
        target_label = "__address__";
        replacement = "127.0.0.1:9115";
      }
    ];
  };

  rules = yaml.generate "alerts.yml" {
    groups = [
      {
        name = "media";
        rules = [
          {
            alert = "ServiceDown";
            expr = ''probe_success{job="services"} == 0'';
            "for" = "5m";
            annotations = {
              summary = "${serviceName} is down{{ if eq $labels.instance \"http://127.0.0.1:8080/\" }} (or the VPN tunnel is){{ end }}";
              resolved = "${serviceName} is back up";
            };
          }
          {
            alert = "PublicSiteDown";
            expr = ''probe_success{job="public"} == 0'';
            "for" = "5m";
            annotations = {
              summary = "${host} is down";
              resolved = "${host} is back up";
            };
          }
          {
            alert = "CertificateExpiring";
            expr = ''probe_ssl_earliest_cert_expiry{job="public"} - time() < 14 * 86400'';
            "for" = "1h";
            annotations = {
              summary = "${host} certificate expires in under 14 days";
              resolved = "${host} certificate renewed";
            };
          }
          {
            alert = "ExporterDown";
            expr = "up == 0";
            "for" = "5m";
            annotations = {
              summary = "Can't scrape {{ $labels.job }}";
              resolved = "Scraping {{ $labels.job }} again";
            };
          }
          {
            alert = "DiskSpaceLow";
            expr = ''node_filesystem_avail_bytes{mountpoint=~"/System/Volumes/Data|/Volumes/.+"} / node_filesystem_size_bytes < 0.10'';
            "for" = "10m";
            annotations = {
              summary = "{{ $labels.mountpoint }} is under 10% free";
              resolved = "{{ $labels.mountpoint }} is back over 10% free";
            };
          }
          {
            alert = "JobFailing";
            expr = "launchd_job_last_exit_status != 0 and launchd_job_running == 0";
            "for" = "30m";
            annotations = {
              summary = "{{ $labels.name }} is failing (exit {{ $value }})";
              resolved = "{{ $labels.name }} recovered";
            };
          }
          {
            alert = "JobRestarting";
            expr = ''increase(launchd_job_runs_total{keepalive="1"}[15m]) > 3'';
            "for" = "15m";
            annotations = {
              summary = "{{ $labels.name }} restarted {{ $value | printf \"%.0f\" }} times in 15 minutes";
              resolved = "{{ $labels.name }} stopped restarting";
            };
          }
          {
            alert = "JobMetricsStale";
            expr = ''time() - node_textfile_mtime_seconds{file=~".*/launchd-.*"} > 600 or node_textfile_scrape_error == 1 or absent(launchd_job_running)'';
            "for" = "10m";
            annotations = {
              summary = "launchd job metrics are stale";
              resolved = "launchd job metrics are updating again";
            };
          }
          {
            # jellyfin_stream_count has no series while nothing is playing
            alert = "JellyfinRestartPending";
            expr = "jellyfin_pending_restart == 1 unless on () sum(jellyfin_stream_count) > 0";
            "for" = "1h";
            annotations = {
              summary = "Jellyfin needs a restart (nothing has played for an hour)";
              resolved = "Jellyfin no longer needs a restart";
            };
          }
          {
            # Cleared by marking the events resolved on Cleanuparr's Events page
            alert = "CleanuparrActionRequired";
            expr = "cleanuparr_unresolved_events > 0";
            annotations = {
              summary = "Cleanuparr has {{ $value }} unresolved {{ $labels.type }} event(s) for {{ $labels.instance }}";
              resolved = "Cleanuparr's {{ $labels.type }} events for {{ $labels.instance }} are resolved";
            };
          }
        ];
      }
    ];
  };

  config = yaml.generate "prometheus.yml" {
    global = {
      scrape_interval = "30s";
      evaluation_interval = "30s";
    };

    rule_files = [ "${rules}" ];
    alerting.alertmanagers = [ { static_configs = [ { targets = [ "127.0.0.1:9093" ]; } ]; } ];

    scrape_configs = [
      (probe "services" (map (s: s.url) services))
      (probe "public" [
        "https://stream.ted.ooo/health"
        "https://request.ted.ooo/api/v1/status"
        # Not status.json, which would keep the snapshot refreshing every 5 minutes
        "https://status.ted.ooo/health"
      ])
      # No alerts: these only show whether a public site failure is Cloudflare's
      # path or the whole connection. request. and status. land on Cloudflare's
      # Atlanta site, www.cloudflare.com on a nearer one, Google off Cloudflare.
      (probe "internet" [
        "https://www.cloudflare.com/cdn-cgi/trace"
        "https://www.google.com/generate_204"
      ])
      {
        job_name = "blackbox";
        static_configs = [ { targets = [ "127.0.0.1:9115" ]; } ];
      }
      {
        job_name = "node_exporter";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
        metric_relabel_configs = keep [
          "cleanuparr_unresolved_events"
          "jellyfin_pending_restart"
          "launchd_job_last_exit_status"
          "launchd_job_running"
          "launchd_job_runs_total"
          "node_boot_time_seconds"
          "node_cpu_seconds_total"
          "node_disk_read_bytes_total"
          "node_disk_read_time_seconds_total"
          "node_disk_reads_completed_total"
          "node_disk_write_time_seconds_total"
          "node_disk_writes_completed_total"
          "node_disk_written_bytes_total"
          "node_filesystem_avail_bytes"
          "node_filesystem_size_bytes"
          "node_load1"
          "node_load5"
          "node_load15"
          "node_memory_active_bytes"
          "node_memory_free_bytes"
          "node_memory_inactive_bytes"
          "node_memory_purgeable_bytes"
          "node_memory_swap_total_bytes"
          "node_memory_wired_bytes"
          "node_network_receive_bytes_total"
          "node_network_receive_errs_total"
          "node_network_receive_packets_total"
          "node_network_transmit_bytes_total"
          "node_network_transmit_errs_total"
          "node_network_transmit_packets_total"
          "node_scrape_collector_duration_seconds"
          "node_textfile_mtime_seconds"
          "node_textfile_scrape_error"
          "node_time_seconds"
        ];
      }
      {
        job_name = "jellyfin";
        static_configs = [ { targets = [ "127.0.0.1:8096" ]; } ];
        metric_relabel_configs = keep [ "http_requests_in_progress" ];
      }
      {
        job_name = "jellyfin-metrics";
        static_configs = [ { targets = [ "127.0.0.1:8097" ]; } ];
      }
      {
        job_name = "macos-process-metrics";
        static_configs = [ { targets = [ "127.0.0.1:9105" ]; } ];
      }
    ];
  };

  checkedConfig = pkgs.runCommand "prometheus.yml" { } ''
    ${pkgs.prometheus.cli}/bin/promtool check rules ${rules}
    ${pkgs.prometheus.cli}/bin/promtool check config --syntax-only ${config}
    cp ${config} $out
  '';
in
{
  launchd.user.agents.prometheus.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = lib.ted.waitForNix [
      "${pkgs.prometheus}/bin/prometheus"
      "--config.file=${checkedConfig}"
      "--storage.tsdb.path=${promData}"
      "--storage.tsdb.retention.time=5y"
      "--web.listen-address=127.0.0.1:9090"
    ];
  };
}
