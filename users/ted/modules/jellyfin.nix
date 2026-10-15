{ pkgs, lib, ... }:
let
  mediaDir = "/Volumes/media";
  dataDir = "/Users/ted/.local/share/jellyfin";
  cfgDir = "/Users/ted/.config/jellyfin";
  log = "/Users/ted/Library/Logs/jellyfin.log";

  start = pkgs.writeShellScript "start-jellyfin" ''
    until [ -d ${mediaDir} ]; do
      echo "waiting for ${mediaDir}"
      sleep 2
    done

    mkdir -p ${dataDir}

    exec ${pkgs.jellyfin}/bin/jellyfin \
      --datadir ${dataDir} \
      --configdir ${cfgDir} \
      --cachedir ${dataDir}/cache \
      --logdir ${dataDir}/log \
      --ffmpeg ${pkgs.jellyfin-ffmpeg}/bin/ffmpeg
  '';
in
{
  home.file.".config/jellyfin/network.xml".text = lib.ted.readConfig "jellyfin/network.xml";

  launchd.user.agents.jellyfin.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };
}
