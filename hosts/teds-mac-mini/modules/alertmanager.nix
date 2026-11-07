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
        # Just the summaries, instead of every label and a Prometheus link;
        # the embed is red while firing and green once resolved. Resolved
        # alerts use the rule's `resolved` annotation ("X is back up"), since
        # "Resolved: X is down" reads as if it's still down
        discord_configs = [
          {
            webhook_url_file = webhookFile;
            title = ''{{ if eq (len .Alerts) 1 }}{{ with index .Alerts 0 }}{{ if ne .Status "resolved" }}{{ .Annotations.summary }}{{ else if .Annotations.resolved }}{{ .Annotations.resolved }}{{ else }}Resolved: {{ .Annotations.summary }}{{ end }}{{ end }}{{ else }}{{ with .Alerts.Firing }}{{ len . }} firing{{ end }}{{ if and .Alerts.Firing .Alerts.Resolved }}, {{ end }}{{ with .Alerts.Resolved }}{{ len . }} resolved{{ end }}{{ end }}'';
            message = ''{{ if gt (len .Alerts) 1 }}{{ range .Alerts.Firing }}🔴 {{ .Annotations.summary }}{{ "\n" }}{{ end }}{{ range .Alerts.Resolved }}✅ {{ with .Annotations.resolved }}{{ . }}{{ else }}{{ .Annotations.summary }}{{ end }}{{ "\n" }}{{ end }}{{ end }}'';
          }
        ];
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
