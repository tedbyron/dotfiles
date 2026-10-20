{ pkgs, unstable, ... }:
let
  mediaDir = "/Volumes/media";
  dataDir = "/Users/ted/.local/share/jellyfin";
  cfgDir = "/Users/ted/.config/jellyfin";
  log = "/Users/ted/Library/Logs/jellyfin.log";

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

    exec ${unstable.jellyfin}/bin/jellyfin \
      --datadir ${dataDir} \
      --configdir ${cfgDir} \
      --cachedir ${dataDir}/cache \
      --logdir ${dataDir}/log
  '';

  subtitleDefaults = {
    SubtitleMode = "Smart";
    SubtitleLanguagePreference = "eng";
  };

  userDefaults = pkgs.writeText "jellyfin-user-defaults.py" ''
    import json, sys, urllib.request

    token_file, template_name, subtitle_defaults = sys.argv[1:]
    token = open(token_file).read().strip()
    subtitle_defaults = json.loads(subtitle_defaults)

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
        with urllib.request.urlopen(req) as r:
            data = r.read()
            return json.loads(data) if data else None

    def prefs_path(user):
        return f"/DisplayPreferences/usersettings?userId={user['Id']}&client=emby"

    users = call("GET", "/Users")
    template = next(u for u in users if u["Name"] == template_name)
    sections = {
        k: v
        for k, v in call("GET", prefs_path(template))["CustomPrefs"].items()
        if k.startswith("homesection")
    }
    if not sections:
        sys.exit(f"{template_name} has no home layout")

    for user in users:
        config = user["Configuration"]
        changed = False

        prefs = call("GET", prefs_path(user))
        if "homesection0" not in prefs["CustomPrefs"]:
            prefs["CustomPrefs"].update(sections)
            call("POST", prefs_path(user), prefs)
            config["OrderedViews"] = template["Configuration"]["OrderedViews"]
            changed = True
            print(f"applied {template_name}'s home layout to {user['Name']}")

        if not config.get("SubtitleLanguagePreference"):
            config.update(subtitle_defaults)
            changed = True
            print(f"applied subtitle defaults to {user['Name']}")

        if changed:
            call("POST", f"/Users/{user['Id']}/Configuration", config)
  '';
in
{
  launchd.user.agents.jellyfin.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };

  launchd.user.agents.jellyfin-user-defaults.serviceConfig = {
    ProgramArguments = [
      "${pkgs.python3}/bin/python3"
      "-I"
      "${userDefaults}"
      "/Users/ted/.config/jelly-metrics/token"
      "tb"
      (builtins.toJSON subtitleDefaults)
    ];
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
