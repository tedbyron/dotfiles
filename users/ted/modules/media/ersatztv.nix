{ pkgs, unstable, ... }:
let
  dataDir = "/Users/ted/Library/Application Support/ersatztv";
  ffmpegDir = "${dataDir}/ffmpeg";
  log = "/Users/ted/Library/Logs/ersatztv.log";

  ffmpeg = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "ersatztv-ffmpeg";
    version = "8.1.2-4";

    src = pkgs.fetchurl {
      url = "https://github.com/ErsatzTV/ErsatzTV-ffmpeg/releases/download/${version}/ffmpeg-n8.1.2-etv.4-macosarm64-gpl-8.1.tar.xz";
      hash = "sha256-RcDRk0EPuod9vKdy7IMDf193ER+FnAO94Hqql0M1DGw=";
    };

    dontFixup = true;

    installPhase = ''
      mkdir -p $out
      cp -R bin $out/
    '';
  };

  start = pkgs.writeShellScript "start-ersatztv" ''
    until [ -d /Volumes/media/movies ]; do
      echo "waiting for /Volumes/media"
      sleep 5
    done

    mkdir -p "${dataDir}"
    ln -sfn ${ffmpeg}/bin "${ffmpegDir}"

    if [ -e "${dataDir}/ersatztv.sqlite3" ]; then
      ${pkgs.sqlite}/bin/sqlite3 "${dataDir}/ersatztv.sqlite3" "
        UPDATE ConfigElement SET Value = '${ffmpegDir}/ffmpeg' WHERE Key = 'ffmpeg.ffmpeg_path';
        UPDATE ConfigElement SET Value = '${ffmpegDir}/ffprobe' WHERE Key = 'ffmpeg.ffprobe_path';
      "
    fi

    export PATH="${ffmpegDir}:$PATH"
    exec ${unstable.ersatztv}/bin/ErsatzTV
  '';

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
      ''
        /sbin/pfctl -a com.apple/ersatztv -s rules 2>/dev/null | grep -q 8409 || /sbin/pfctl -a com.apple/ersatztv -f ${pfRules}
        /sbin/pfctl -s info 2>/dev/null | grep -q 'Status: Enabled' || /sbin/pfctl -E
      ''
    ];
    RunAtLoad = true;
    StartInterval = 60;
    StandardErrorPath = "/var/log/ersatztv-pf.log";
    StandardOutPath = "/var/log/ersatztv-pf.log";
  };
}
