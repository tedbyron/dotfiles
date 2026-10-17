{ pkgs, lib, ... }:
let
  dataDir = "/Users/ted/.local/share/bazarr";
  configFile = "${dataDir}/config/config.yaml";
  log = "/Users/ted/Library/Logs/bazarr.log";

  start = pkgs.writeShellScript "start-bazarr" ''
    mkdir -p ${dataDir}/config
    touch ${configFile}
    ${lib.getExe pkgs.yq-go} -i '.general.ip = "127.0.0.1" | .general.port = 6767' ${configFile}

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
