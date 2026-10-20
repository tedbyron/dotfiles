{ pkgs, ... }:
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
            annotations.summary = "{{ $labels.instance }} has not responded for 5 minutes (qBittorrent at :8080 also stops when the VPN tunnel is down)";
          }
          {
            alert = "PublicSiteDown";
            expr = ''probe_success{job="public"} == 0'';
            "for" = "5m";
            annotations.summary = "{{ $labels.instance }} has not responded for 5 minutes";
          }
          {
            alert = "CertificateExpiring";
            expr = ''probe_ssl_earliest_cert_expiry{job="public"} - time() < 14 * 86400'';
            "for" = "1h";
            annotations.summary = "TLS certificate for {{ $labels.instance }} expires in under 14 days";
          }
          {
            alert = "ExporterDown";
            expr = "up == 0";
            "for" = "5m";
            annotations.summary = "Prometheus cannot scrape {{ $labels.job }}";
          }
          {
            alert = "DiskSpaceLow";
            expr = ''node_filesystem_avail_bytes{mountpoint=~"/System/Volumes/Data|/Volumes/.+"} / node_filesystem_size_bytes < 0.10'';
            "for" = "10m";
            annotations.summary = "{{ $labels.mountpoint }} has less than 10% free";
          }
          {
            alert = "JobFailing";
            expr = "launchd_job_last_exit_status != 0 and launchd_job_running == 0";
            "for" = "30m";
            annotations.summary = "{{ $labels.name }} last exited with status {{ $value }}";
          }
          {
            alert = "JobMetricsStale";
            expr = ''time() - node_textfile_mtime_seconds{file=~".*/launchd-.*"} > 600 or node_textfile_scrape_error == 1 or absent(launchd_job_running)'';
            "for" = "10m";
            annotations.summary = "launchd job status metrics have stopped updating";
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
      (probe "services" [
        "http://127.0.0.1:8096/health"
        "http://127.0.0.1:5055/api/v1/status"
        "http://127.0.0.1:8989/ping"
        "http://127.0.0.1:7878/ping"
        "http://127.0.0.1:9696/ping"
        "http://127.0.0.1:11011/health"
        "http://127.0.0.1:6767/"
        "http://127.0.0.1:8080/"
        "http://127.0.0.1:8409/"
        "http://127.0.0.1:8191/"
        "http://127.0.0.1:3000/api/health"
      ])
      (probe "public" [
        "https://stream.ted.ooo/health"
        "https://request.ted.ooo/api/v1/status"
      ])
      {
        job_name = "blackbox";
        static_configs = [ { targets = [ "127.0.0.1:9115" ]; } ];
      }
      {
        job_name = "node_exporter";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
        metric_relabel_configs = keep [
          "launchd_job_last_exit_status"
          "launchd_job_running"
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

    ProgramArguments = [
      "${pkgs.prometheus}/bin/prometheus"
      "--config.file=${checkedConfig}"
      "--storage.tsdb.path=${promData}"
      "--storage.tsdb.retention.time=5y"
      "--web.listen-address=127.0.0.1:9090"
    ];
  };
}
