{ pkgs, lib, ... }:
let
  backupDir = "/Volumes/media/backups";
  stage = "/Users/ted/Backups/media/staging";
  keep = 14;
  log = "/Users/ted/Library/Logs/media-backup.log";
  share = "/Users/ted/.local/share";
  appSupport = "/Users/ted/Library/Application Support";

  arrExcludes = [
    "logs/"
    "logs.db*"
    "MediaCover/"
    "Sentry/"
    "*.pid"
  ];

  sources = [
    {
      name = "jellyfin-config";
      path = "/Users/ted/.config/jellyfin";
      exclude = [ ];
    }
    {
      name = "jellyfin";
      path = "${share}/jellyfin";
      exclude = [
        "cache/"
        "log/"
        "metadata/"
        "data/trickplay/"
      ];
    }
    {
      name = "sonarr";
      path = "${share}/sonarr";
      exclude = arrExcludes;
    }
    {
      name = "radarr";
      path = "${share}/radarr";
      exclude = arrExcludes;
    }
    {
      name = "prowlarr";
      path = "${share}/prowlarr";
      exclude = arrExcludes;
    }
    {
      name = "cleanuparr";
      path = "${share}/cleanuparr";
      exclude = [ "logs/" ];
    }
    {
      name = "seerr";
      path = "${share}/seerr";
      exclude = [
        "cache/"
        "logs/"
      ];
    }
    {
      name = "bazarr";
      path = "${share}/bazarr";
      exclude = [
        "cache/"
        "log/"
      ];
    }
    {
      name = "grafana";
      path = "${share}/grafana";
      exclude = [
        "log/"
        "plugins/"
      ];
    }
    {
      name = "ersatztv";
      path = "${appSupport}/ersatztv";
      exclude = [
        "cache/"
        "ffmpeg"
        "logs/"
        "search-index/"
        "temp-pool/"
      ];
    }
    {
      name = "qbittorrent";
      path = "${appSupport}/qBittorrent";
      exclude = [
        "GeoDB/"
        "logs/"
      ];
    }
    {
      name = "qbittorrent-config";
      path = "/Users/ted/.config/qBittorrent";
      exclude = [ ];
    }
  ];

  copy =
    source:
    let
      excludes = lib.concatMapStringsSep " " (e: "--exclude ${lib.escapeShellArg e}") source.exclude;
    in
    "copy ${lib.escapeShellArg source.name} ${lib.escapeShellArg source.path} ${excludes}";

  backup = pkgs.writeShellScript "media-backup" ''
    set -euo pipefail
    umask 077

    until [ -d ${backupDir} ]; do
      echo "waiting for ${backupDir}"
      sleep 30
    done

    stage=${stage}
    mkdir -p "$stage"

    copy() {
      local name=$1 src=$2
      shift 2
      if [ ! -d "$src" ]; then
        echo "skipping $name: $src is missing"
        return
      fi

      ${lib.getExe pkgs.rsync} -a --delete --delete-excluded "$@" "$src/" "$stage/$name/"

      find "$stage/$name" -type f \( -name '*.db' -o -name '*.sqlite' -o -name '*.sqlite3' \) | while read -r copied; do
        rm -f "$copied" "$copied-wal" "$copied-shm" "$copied-journal"
        ${pkgs.sqlite}/bin/sqlite3 "$src/''${copied#"$stage/$name/"}" ".backup '$copied'"
      done
    }

    ${lib.concatMapStringsSep "\n" copy sources}

    archive=${backupDir}/media-$(date +%F).tar.gz
    tar -C "$stage" -czf "$archive.partial" .
    # The NAS makes new files world-readable whatever the umask, and these hold API keys
    chmod 600 "$archive.partial"
    mv "$archive.partial" "$archive"
    echo "wrote $archive ($(du -h "$archive" | cut -f1))"

    find ${backupDir} -maxdepth 1 -name 'media-*.tar.gz' | sort -r | tail -n +${toString (keep + 1)} | while read -r old; do
      echo "removing $old"
      rm -f "$old"
    done
  '';
in
{
  launchd.user.agents.media-backup.serviceConfig = {
    ProgramArguments = [ "${backup}" ];
    StandardErrorPath = log;
    StandardOutPath = log;

    StartCalendarInterval = [
      {
        Hour = 4;
        Minute = 0;
      }
    ];
  };
}
