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

  # Applied on every start, overriding changes made in the web UI
  settings = ''
    .main.enableSpecialEpisodes = false
    | .jellyfin.libraries |= map(.enabled = true)
    | .radarr |= map(.activeDirectory = "/Volumes/media/movies")
    | .sonarr |= map(.activeDirectory = "/Volumes/media/tv")
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
    ProgramArguments = [ "${start}" ];
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
