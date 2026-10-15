{ pkgs, ... }:
let
  dataDir = "/Users/ted/Library/Application Support/ersatztv";
  ffmpegDir = "${dataDir}/ffmpeg";
  log = "/Users/ted/Library/Logs/ersatztv.log";

  start = pkgs.writeShellScript "start-ersatztv" ''
    mkdir -p "${dataDir}"
    ln -sfn ${pkgs.ffmpeg_7.bin}/bin "${ffmpegDir}"

    if [ -e "${dataDir}/ersatztv.sqlite3" ]; then
      ${pkgs.sqlite}/bin/sqlite3 "${dataDir}/ersatztv.sqlite3" "
        UPDATE ConfigElement SET Value = '${ffmpegDir}/ffmpeg' WHERE Key = 'ffmpeg.ffmpeg_path';
        UPDATE ConfigElement SET Value = '${ffmpegDir}/ffprobe' WHERE Key = 'ffmpeg.ffprobe_path';
      "
    fi

    export PATH="${ffmpegDir}:$PATH"
    exec ${pkgs.ersatztv}/bin/ErsatzTV
  '';

  # ErsatzTV can't bind to localhost only
  pfRules = pkgs.writeText "ersatztv.pf" ''
    block drop in quick on ! lo0 proto { tcp udp } to any port 8409
  '';
in
{
  launchd.user.agents.ersatztv.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    EnvironmentVariables = {
      ETV_UI_PORT = "8409";
      ETV_STREAMING_PORT = "8409";
    };
  };

  launchd.daemons.ersatztv-pf.serviceConfig = {
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "/sbin/pfctl -a com.apple/ersatztv -f ${pfRules} && /sbin/pfctl -E"
    ];
    RunAtLoad = true;
    StandardErrorPath = "/var/log/ersatztv-pf.log";
    StandardOutPath = "/var/log/ersatztv-pf.log";
  };
}
