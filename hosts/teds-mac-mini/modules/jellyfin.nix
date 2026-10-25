{
  pkgs,
  lib,
  unstable,
  mediaLaunch,
  ...
}:
let
  mediaDir = "/Volumes/media";
  dataDir = "/Users/ted/.local/share/jellyfin";
  cfgDir = "/Users/ted/.config/jellyfin";
  log = "/Users/ted/Library/Logs/jellyfin.log";

  # jellyfin-ffmpeg's VERSION file shadows libc++'s <version> on macOS's
  # case-insensitive filesystem, breaking the C++ OpenColorIO wrapper that
  # ffmpeg 8.1 enables; Jellyfin doesn't use the ocio filter
  jellyfin = unstable.jellyfin.override {
    jellyfin-ffmpeg = unstable.jellyfin-ffmpeg.override {
      ffmpeg_8-full = unstable.ffmpeg_8-full.override { withOpenColorIO = false; };
    };
  };

  networkXml = pkgs.writeText "network.xml" ''
    <?xml version="1.0" encoding="utf-8"?>
    <NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <EnableRemoteAccess>true</EnableRemoteAccess>
      <KnownProxies>
        <string>127.0.0.1</string>
        <string>::1</string>
      </KnownProxies>
    </NetworkConfiguration>
  '';

  # NFS reports no file creation time, so Jellyfin would date every NAS item 1970
  metadataXml = pkgs.writeText "metadata.xml" ''
    <?xml version="1.0" encoding="utf-8"?>
    <MetadataConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <UseFileCreationTimeForDateAdded>false</UseFileCreationTimeForDateAdded>
    </MetadataConfiguration>
  '';

  # For ASS subtitles (anime signs and songs) whose fonts aren't attached to the
  # file. The web player downloads every fallback font before showing ASS
  # subtitles, so this is one ~6 MB font covering Japanese and Latin, not Noto CJK
  fallbackFonts = pkgs.runCommand "jellyfin-fallback-fonts" { } ''
    mkdir $out
    cp ${pkgs.ipaexfont}/share/fonts/truetype/ipaexg.ttf $out/
  '';

  start = pkgs.writeShellScript "start-jellyfin" ''
    mkdir -p ${dataDir} ${cfgDir}

    until [ -d ${mediaDir}/movies ]; do
      echo "waiting for ${mediaDir}"
      sleep 2
    done

    if [ ! -e ${cfgDir}/network.xml ]; then
      rm -f ${cfgDir}/network.xml
      ${pkgs.coreutils}/bin/install -m 644 ${networkXml} ${cfgDir}/network.xml
    fi

    ${pkgs.coreutils}/bin/install -m 644 ${metadataXml} ${cfgDir}/metadata.xml

    if [ -e ${cfgDir}/system.xml ]; then
      ${pkgs.gnused}/bin/sed -i \
        's|<EnableMetrics>false</EnableMetrics>|<EnableMetrics>true</EnableMetrics>|' \
        ${cfgDir}/system.xml
    fi

    ln -sfn ${fallbackFonts} ${dataDir}/fonts
    if [ -e ${cfgDir}/encoding.xml ]; then
      ${pkgs.gnused}/bin/sed -i \
        -e '/<FallbackFontPath>/d' \
        -e 's|<EnableFallbackFont>.*</EnableFallbackFont>|<EnableFallbackFont>true</EnableFallbackFont>\n  <FallbackFontPath>${dataDir}/fonts</FallbackFontPath>|' \
        ${cfgDir}/encoding.xml
    fi

    exec ${jellyfin}/bin/jellyfin \
      --datadir ${dataDir} \
      --configdir ${cfgDir} \
      --cachedir ${dataDir}/cache \
      --logdir ${dataDir}/log
  '';

  subtitleDefaults = {
    SubtitleMode = "Smart";
    SubtitleLanguagePreference = "eng";
  };

  # Files often flag a dub as the default track, which would win over OriginalLanguage
  audioDefaults = {
    AudioLanguagePreference = "OriginalLanguage";
    PlayDefaultAudioTrack = false;
  };

  userDefaults = pkgs.writeText "jellyfin-user-defaults.py" ''
    import json, sys, time, urllib.request

    token_file, template_name, subtitle_defaults, audio_defaults = sys.argv[1:]
    token = open(token_file).read().strip()
    subtitle_defaults = json.loads(subtitle_defaults)
    audio_defaults = json.loads(audio_defaults)

    def call(method, path, body=None):
        req = urllib.request.Request(
            "http://127.0.0.1:8096" + path,
            method=method,
            data=None if body is None else json.dumps(body).encode(),
            headers={
                "Authorization": f'MediaBrowser Token="{token}"',
                "Content-Type": "application/json",
            },
        )
        with urllib.request.urlopen(req, timeout=30) as r:
            data = r.read()
            return json.loads(data) if data else None

    def prefs_path(user):
        return f"/DisplayPreferences/usersettings?userId={user['Id']}&client=emby"

    # Runs only at load and 5am, and at boot Jellyfin can wait a long time for the NAS
    while True:
        try:
            call("GET", "/System/Info/Public")
            break
        except OSError:
            time.sleep(10)

    users = call("GET", "/Users")
    template = next(u for u in users if u["Name"] == template_name)
    # Everything on the Settings -> Home page
    home_prefs = {
        k: v
        for k, v in call("GET", prefs_path(template))["CustomPrefs"].items()
        if k.startswith("homesection") or k == "useEpisodeImagesInNextUpAndResume"
    }
    if "homesection0" not in home_prefs:
        sys.exit(f"{template_name} has no home layout")
    home_config = {
        k: template["Configuration"][k]
        for k in ["GroupedFolders", "LatestItemsExcludes", "HidePlayedInLatest"]
    }

    # Grouped views and Playlists have a different ID for each user, so views
    # are copied by name and type
    def views(user):
        items = call("GET", f"/UserViews?userId={user['Id']}&includeHidden=true")
        return {(v["Name"], v.get("CollectionType")): v["Id"] for v in items["Items"]}

    template_views = {v: k for k, v in views(template).items()}

    def copy_views(user, config):
        ids = views(user)
        for k in ["OrderedViews", "MyMediaExcludes"]:
            config[k] = [
                ids[template_views[v]]
                for v in template["Configuration"][k]
                if template_views.get(v) in ids
            ]

    for user in users:
        config = user["Configuration"]
        changed = False

        prefs = call("GET", prefs_path(user))
        if user["Id"] != template["Id"] and "homesection0" not in prefs["CustomPrefs"]:
            prefs["CustomPrefs"].update(home_prefs)
            call("POST", prefs_path(user), prefs)
            config.update(home_config)
            # Grouping changes the user's views, so apply it before copying them
            call("POST", f"/Users/{user['Id']}/Configuration", config)
            copy_views(user, config)
            changed = True
            print(f"applied {template_name}'s home layout to {user['Name']}")

        if not config.get("SubtitleLanguagePreference"):
            config.update(subtitle_defaults)
            changed = True
            print(f"applied subtitle defaults to {user['Name']}")

        if not config.get("AudioLanguagePreference"):
            config.update(audio_defaults)
            changed = True
            print(f"applied audio defaults to {user['Name']}")

        if changed:
            call("POST", f"/Users/{user['Id']}/Configuration", config)
  '';

  userDefaultsArgs = [
    "${pkgs.python3}/bin/python3"
    "-I"
    "${userDefaults}"
    "/Users/ted/.config/jelly-metrics/token"
    "tb"
    (builtins.toJSON subtitleDefaults)
    (builtins.toJSON audioDefaults)
  ];
in
{
  launchd.user.agents.jellyfin.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = mediaLaunch [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };

  launchd.user.agents.jellyfin-user-defaults.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix userDefaultsArgs;
    RunAtLoad = true;
    StandardErrorPath = "/Users/ted/Library/Logs/jellyfin-user-defaults.log";
    StandardOutPath = "/Users/ted/Library/Logs/jellyfin-user-defaults.log";

    StartCalendarInterval = [
      {
        Hour = 5;
        Minute = 0;
      }
    ];
  };
}
