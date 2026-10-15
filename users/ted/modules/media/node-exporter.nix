{ pkgs, ... }:
let
  log = "/Users/ted/Library/Logs/node-exporter.log";
in
{
  launchd.user.agents.node-exporter.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = [
      "${pkgs.prometheus-node-exporter}/bin/node_exporter"
      "--web.listen-address=127.0.0.1:9100"
    ];
  };
}
