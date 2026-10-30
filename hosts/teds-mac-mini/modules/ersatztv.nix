{
  pkgs,
  lib,
  unstable,
  mediaLaunch,
  ...
}:
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
        -- Libraries are discovered at startup with sync off, so a new one syncs from the next start.
        -- Not the 4K libraries, whose copies would put titles in the channels twice
        UPDATE JellyfinLibrary SET ShouldSyncItems =
          (SELECT Name FROM Library WHERE Library.Id = JellyfinLibrary.Id) NOT IN ('Movies 4K', 'Shows 4K');
      "
    fi

    export PATH="${ffmpegDir}:$PATH"
    exec ${unstable.ersatztv}/bin/ErsatzTV
  '';

  # Upgrades and replacements give the new file a new Jellyfin item, and
  # ErsatzTV keeps scheduling the missing old one until its trash is emptied
  trash = pkgs.writeText "ersatztv-trash.py" ''
    import json, sqlite3, sys, time, urllib.request

    db_path, secrets, jellyfin_token_file = sys.argv[1:]
    etv_auth = {"X-Etv-Api-Key": json.load(open(secrets))["ApiKey"]}
    jellyfin_auth = {
        "Authorization": f'MediaBrowser Token="{open(jellyfin_token_file).read().strip()}"'
    }

    def call(url, headers, method="GET"):
        req = urllib.request.Request(url, method=method, headers=headers)
        with urllib.request.urlopen(req, timeout=30) as r:
            data = r.read()
            return json.loads(data) if data else None

    def etv(path, method="GET"):
        return call("http://127.0.0.1:8409" + path, etv_auth, method)

    def jellyfin(path, method="GET"):
        return call("http://127.0.0.1:8096" + path, jellyfin_auth, method)

    def query(sql):
        with sqlite3.connect(f"file:{db_path}?mode=ro", uri=True) as db:
            return [row[0] for row in db.execute(sql)]

    # FileNotFound, the only state empty_trash deletes. RemoteOnly and Unavailable
    # items become FileNotFound once a library sync no longer finds them in Jellyfin
    def stale():
        return query("SELECT count(*) FROM MediaItem WHERE State = 1")[0]

    if not stale():
        sys.exit(0)

    # Resetting a playout changes what's on now, so wait for nobody to be watching
    if etv("/api/sessions"):
        print("skipping, channels are being watched")
        sys.exit(0)

    channels = query("""
        SELECT DISTINCT c.Number FROM PlayoutItem pi
        JOIN MediaItem mi ON mi.Id = pi.MediaItemId
        JOIN Playout p ON p.Id = pi.PlayoutId
        JOIN Channel c ON c.Id = p.ChannelId
        WHERE mi.State = 1
    """)

    print(f"emptying trash of {stale()} items")
    etv("/api/maintenance/empty_trash", "POST")
    for _ in range(30):
        if not stale():
            break
        time.sleep(2)
    else:
        sys.exit("trash didn't empty")

    for number in channels:
        print(f"resetting channel {number}")
        etv(f"/api/channels/{number}/playout/reset", "POST")

    if channels:
        task = next(t for t in jellyfin("/ScheduledTasks") if t["Key"] == "RefreshGuide")
        jellyfin(f"/ScheduledTasks/Running/{task['Id']}", "POST")
        print("refreshing jellyfin guide")
  '';

  pfRules = pkgs.writeText "ersatztv.pf" ''
    block drop in quick on ! lo0 proto { tcp udp } to any port 8409
  '';
in
{
  launchd.user.agents.ersatztv.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = mediaLaunch [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    EnvironmentVariables = {
      ETV_UI_PORT = "8409";
      ETV_STREAMING_PORT = "8409";
    };
  };

  launchd.user.agents.ersatztv-trash.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [
      "${pkgs.python3}/bin/python3"
      "-I"
      "${trash}"
      "${dataDir}/ersatztv.sqlite3"
      "${dataDir}/api-secrets.json"
      "/Users/ted/.config/jelly-metrics/token"
    ];
    StandardErrorPath = "/Users/ted/Library/Logs/ersatztv-trash.log";
    StandardOutPath = "/Users/ted/Library/Logs/ersatztv-trash.log";
    StartInterval = 3600;
  };

  launchd.daemons.ersatztv-pf.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [
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
