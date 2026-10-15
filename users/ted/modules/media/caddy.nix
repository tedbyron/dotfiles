{ pkgs, ... }:
let
  log = "/Users/ted/Library/Logs/caddy.log";

  caddyfile = pkgs.writeText "Caddyfile" ''
    j.tedbyron.com {
      @metrics path /metrics*
      respond @metrics 403
      reverse_proxy 127.0.0.1:8096
    }
  '';
in
{
  launchd.user.agents.caddy.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = [
      "${pkgs.caddy}/bin/caddy"
      "run"
      "--config"
      "${caddyfile}"
      "--adapter"
      "caddyfile"
    ];
  };
}
