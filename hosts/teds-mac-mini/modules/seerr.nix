{
  pkgs,
  lib,
  unstable,
  ...
}:
let
  dataDir = "/Users/ted/.local/share/seerr";
  log = "/Users/ted/Library/Logs/seerr.log";

  seerr = unstable.seerr.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [
      pkgs.cctools
      pkgs.xcbuild
    ];

    meta = old.meta // {
      platforms = lib.platforms.unix;
    };
  });

  # Applied on every start, overriding changes made in the web UI. Requests are
  # tagged with the requester ("5-tb"), which Radarr and Sonarr use to send tb's
  # downloads to the bottom of qBittorrent's queue. The webhook goes to tedbot,
  # which posts new and available requests in Discord and forwards everything
  # to Moonfin (its URL and secret are in tedbot's config). Its types are a
  # bitmask; 128 is "Request Automatically Approved", so tedbot sees every new
  # request, not only ones waiting for approval.
  settings = ''
    .main.enableSpecialEpisodes = false
    | .notifications.agents.webhook.enabled = true
    | .notifications.agents.webhook.options.webhookUrl = "http://127.0.0.1:5056/seerr"
    | .notifications.agents.webhook.types |= (if (. / 128 | floor) % 2 == 0 then . + 128 else . end)
    | .jellyfin.libraries |= map(.enabled = true)
    | .radarr |= map(.activeDirectory = "/Volumes/media/movies" | .tagRequests = true)
    | .sonarr |= map(.activeDirectory = "/Volumes/media/tv" | .activeAnimeDirectory = "/Volumes/media/anime" | .tagRequests = true)
  '';

  start = pkgs.writeShellScript "start-seerr" ''
    file=${dataDir}/settings.json
    if [ -e "$file" ]; then
      ${lib.getExe pkgs.jq} ${lib.escapeShellArg settings} "$file" > "$file.tmp" \
        && mv "$file.tmp" "$file"
    fi

    exec ${lib.getExe seerr}
  '';
in
{
  launchd.user.agents.seerr.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = lib.ted.waitForNix [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    EnvironmentVariables = {
      CONFIG_DIRECTORY = dataDir;
      HOST = "127.0.0.1";
      PORT = "5055";
    };
  };
}
