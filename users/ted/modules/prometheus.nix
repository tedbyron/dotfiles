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

  config = (pkgs.formats.yaml { }).generate "prometheus.yml" {
    global.scrape_interval = "30s";

    scrape_configs = [
      {
        job_name = "node_exporter";
        static_configs = [ { targets = [ "127.0.0.1:9100" ]; } ];
        metric_relabel_configs = keep [
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
