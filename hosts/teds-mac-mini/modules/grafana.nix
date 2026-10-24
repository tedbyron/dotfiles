{ pkgs, lib, ... }:
let
  dataDir = "/Users/ted/.local/share/grafana";
  log = "/Users/ted/Library/Logs/grafana.log";

  # Hydra doesn't build nixpkgs' grafana for darwin, so CI spent ~25 minutes
  # building it from source. The release archive is a fixed output, so its path
  # also stays the same across flake updates and is cached once per version.
  grafana =
    let
      version = "13.0.11";
    in
    pkgs.fetchzip {
      name = "grafana-${version}";
      url = "https://dl.grafana.com/oss/release/grafana-${version}.darwin-arm64.tar.gz";
      hash = "sha256-SiiZarBouZYXW4rGabL7nXvvEnrw24l/3diDomN1PSM=";
      # Source maps are a third of the archive
      postFetch = ''
        rm -r $out/{Dockerfile,docs,packaging}
        find $out/public -name '*.map' -delete
      '';
    };

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

  dashboards = (pkgs.formats.yaml { }).generate "dashboards.yaml" {
    apiVersion = 1;
    providers = [
      {
        name = "dotfiles";
        type = "file";
        allowUiUpdates = true;
        options.path = ./grafana;
      }
    ];
  };

  provisioning = pkgs.linkFarm "grafana-provisioning" {
    "datasources/prometheus.yaml" = datasources;
    "dashboards/dotfiles.yaml" = dashboards;
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
      # Only reachable on localhost, so skip the login
      GF_AUTH_ANONYMOUS_ENABLED = "true";
      GF_AUTH_ANONYMOUS_ORG_ROLE = "Admin";
      GF_AUTH_DISABLE_LOGIN_FORM = "true";
    };

    ProgramArguments = lib.ted.waitForNix [
      "${grafana}/bin/grafana"
      "server"
      "--homepath"
      "${grafana}"
    ];
  };
}
