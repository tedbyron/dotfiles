{
  pkgs,
  lib,
  mediaLaunch,
  ...
}:
let
  services = {
    prowlarr = {
      package = pkgs.prowlarr;
      port = 9696;
      allowedHosts = true;
      media = false;
    };
    radarr = {
      package = pkgs.radarr;
      port = 7878;
      allowedHosts = true;
      media = true;
    };
    # Seerr's 4K requests: a second Radarr and Sonarr, since one can't keep two
    # copies of a title
    radarr-4k = {
      package = pkgs.radarr;
      port = 7879;
      allowedHosts = true;
      media = true;
      env = "RADARR";
    };
    sonarr = {
      package = pkgs.sonarr;
      port = 8989;
      allowedHosts = true;
      media = true;
    };
    sonarr-4k = {
      package = pkgs.sonarr;
      port = 8990;
      allowedHosts = true;
      media = true;
      env = "SONARR";
    };
  };
in
{
  launchd.user.agents = lib.mapAttrs (
    name:
    {
      package,
      port,
      allowedHosts,
      media,
      env ? lib.toUpper name,
    }:
    let
      log = "/Users/ted/Library/Logs/${name}.log";
    in
    {
      serviceConfig = {
        KeepAlive = true;
        RunAtLoad = true;
        StandardErrorPath = log;
        StandardOutPath = log;

        EnvironmentVariables = {
          "${env}__SERVER__BINDADDRESS" = "127.0.0.1";
          "${env}__SERVER__PORT" = toString port;
        }
        // lib.optionalAttrs allowedHosts {
          "${env}__SERVER__ALLOWEDHOSTS" = "localhost,127.0.0.1";
        };

        ProgramArguments = (if media then mediaLaunch else lib.ted.waitForNix) (
          lib.optionals media [
            "/bin/sh"
            "-c"
            ''
              until [ -d /Volumes/media/movies ]; do
                echo "waiting for /Volumes/media"
                sleep 5
              done
              exec "$0" "$@"
            ''
          ]
          ++ [
            (lib.getExe package)
            "-nobrowser"
            "-data=/Users/ted/.local/share/${name}"
          ]
        );
      };
    }
  ) services;
}
