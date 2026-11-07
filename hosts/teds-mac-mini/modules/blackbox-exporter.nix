{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/blackbox-exporter.log";

  config = (pkgs.formats.yaml { }).generate "blackbox.yml" {
    modules = {
      http_2xx = {
        prober = "http";
        timeout = "10s";
        http.preferred_ip_protocol = "ip4";
      };
      # For the public sites: a redirect would be Cloudflare Access's login
      # page, which answers 200 whether or not the site behind it is up
      http_2xx_direct = {
        prober = "http";
        timeout = "10s";
        http = {
          preferred_ip_protocol = "ip4";
          follow_redirects = false;
        };
      };
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
