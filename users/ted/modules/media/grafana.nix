{ pkgs, ... }:
let
  dataDir = "/Users/ted/.local/share/grafana";
  log = "/Users/ted/Library/Logs/grafana.log";

  datasources = (pkgs.formats.yaml { }).generate "prometheus.yaml" {
    apiVersion = 1;
    datasources = [
      {
        name = "Prometheus";
        type = "prometheus";
        uid = "prometheus";
        access = "proxy";
        url = "http://127.0.0.1:9090";
        isDefault = true;
      }
    ];
  };

  provisioning = pkgs.linkFarm "grafana-provisioning" {
    "datasources/prometheus.yaml" = datasources;
  };
in
{
  launchd.user.agents.grafana.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    EnvironmentVariables = {
      GF_PATHS_DATA = dataDir;
      GF_PATHS_LOGS = "${dataDir}/log";
      GF_PATHS_PLUGINS = "${dataDir}/plugins";
      GF_PATHS_PROVISIONING = "${provisioning}";
      GF_SERVER_HTTP_ADDR = "127.0.0.1";
      GF_SERVER_HTTP_PORT = "3000";
      GF_ANALYTICS_REPORTING_ENABLED = "false";
      GF_ANALYTICS_CHECK_FOR_UPDATES = "false";
    };

    ProgramArguments = [
      "${pkgs.grafana}/bin/grafana"
      "server"
      "--homepath"
      "${pkgs.grafana}/share/grafana"
    ];
  };
}
