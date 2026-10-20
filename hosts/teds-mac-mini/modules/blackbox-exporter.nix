{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/blackbox-exporter.log";

  config = (pkgs.formats.yaml { }).generate "blackbox.yml" {
    modules.http_2xx = {
      prober = "http";
      timeout = "10s";
      http.preferred_ip_protocol = "ip4";
    };
  };
in
{
  launchd.user.agents.blackbox-exporter.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = lib.ted.waitForNix [
      "${pkgs.prometheus-blackbox-exporter}/bin/blackbox_exporter"
      "--config.file=${config}"
      "--web.listen-address=127.0.0.1:9115"
    ];
  };
}
