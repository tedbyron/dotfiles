{ pkgs, lib, ... }:
let
  dataDir = "/Users/ted/.local/share/bazarr";
  configFile = "${dataDir}/config/config.yaml";
  log = "/Users/ted/Library/Logs/bazarr.log";

  start = pkgs.writeShellScript "start-bazarr" ''
    until [ -d /Volumes/media/movies ]; do
      echo "waiting for /Volumes/media"
      sleep 5
    done

    mkdir -p ${dataDir}/config
    touch ${configFile}
    ${lib.getExe pkgs.yq-go} -i '.general.ip = "127.0.0.1" | .general.port = 6767' ${configFile}

    # A child left behind by a killed wrapper keeps the port, so every new
    # child exits on bind while the orphan serves stale code
    /usr/bin/pkill -9 -f "bazarr/main.py --config ${dataDir}" || true

    export PATH=${lib.makeBinPath [ pkgs.ffmpeg ]}:$PATH
    exec ${pkgs.bazarr}/bin/bazarr --config ${dataDir} --no-update
  '';
in
{
  launchd.user.agents.bazarr.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };
}
