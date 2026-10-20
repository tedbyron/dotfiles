{ pkgs, lib, ... }:
let
  dataDir = "/Users/ted/.local/share/alertmanager";
  webhookFile = "/Users/ted/.config/alertmanager/discord-webhook";
  log = "/Users/ted/Library/Logs/alertmanager.log";

  config = (pkgs.formats.yaml { }).generate "alertmanager.yml" {
    route = {
      receiver = "discord";
      group_by = [ "alertname" ];
      group_wait = "30s";
      group_interval = "5m";
      repeat_interval = "12h";
    };

    receivers = [
      {
        name = "discord";
        discord_configs = [ { webhook_url_file = webhookFile; } ];
      }
    ];
  };

  checkedConfig = pkgs.runCommand "alertmanager.yml" { } ''
    ${pkgs.prometheus-alertmanager}/bin/amtool check-config ${config}
    cp ${config} $out
  '';
in
{
  launchd.user.agents.alertmanager.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = lib.ted.waitForNix [
      "${pkgs.prometheus-alertmanager}/bin/alertmanager"
      "--config.file=${checkedConfig}"
      "--storage.path=${dataDir}"
      "--web.listen-address=127.0.0.1:9093"
      "--cluster.listen-address="
    ];
  };
}
