{ pkgs, self, ... }:
let
  src = self.inputs.speedrr;
  dataDir = "/Users/ted/.local/share/speedrr";
  passwordFile = "/Users/ted/.config/speedrr/qbittorrent-password";
  tokenFile = "/Users/ted/.config/jelly-metrics/token";
  log = "/Users/ted/Library/Logs/speedrr.log";

  python = pkgs.python3.withPackages (p: [
    p.colorama
    p.dataclass-wizard
    p.httpx
    p.pyyaml
    p.qbittorrent-api
    p.transmission-rpc
  ]);

  config = pkgs.writeText "speedrr.json" (
    builtins.toJSON {
      logs_path = null;
      units = "Mbit";
      min_upload = 10;
      max_upload = 250;
      min_download = 10000;
      max_download = 10000;
      manual_speed_algorithm_share = false;

      clients = [
        {
          type = "qbittorrent";
          url = "http://127.0.0.1:8080";
          username = "ted";
          password = "";
          https_verify = true;
        }
      ];

      modules = {
        schedule = null;
        media_servers = [
          {
            type = "jellyfin";
            url = "http://127.0.0.1:8096";
            api_key = "";
            https_verify = true;
            bandwidth_multiplier = 1.0;
            update_interval = 5;
            ignore_streams = {
              local = true;
              ip_networks = null;
              paused_after = 300;
            };
          }
        ];
      };
    }
  );

  start = pkgs.writeShellScript "start-speedrr" ''
    until [ -s ${passwordFile} ] && [ -s ${tokenFile} ]; do
      echo "waiting for ${passwordFile} and ${tokenFile}"
      sleep 30
    done

    umask 077
    mkdir -p ${dataDir}
    ${python}/bin/python3 -I -c '
    import json, sys
    config = json.load(open(sys.argv[1]))
    config["clients"][0]["password"] = open(sys.argv[2]).read().strip()
    config["modules"]["media_servers"][0]["api_key"] = open(sys.argv[3]).read().strip()
    json.dump(config, open(sys.argv[4], "w"))
    ' ${config} ${passwordFile} ${tokenFile} ${dataDir}/config.yaml

    exec ${python}/bin/python3 -E -s ${src}/main.py --config_path ${dataDir}/config.yaml
  '';
in
{
  launchd.user.agents.speedrr.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    ThrottleInterval = 30;
  };
}
