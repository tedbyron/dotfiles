{ pkgs, lib, ... }:
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
    sonarr = {
      package = pkgs.sonarr;
      port = 8989;
      allowedHosts = true;
      media = true;
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
    }:
    let
      log = "/Users/ted/Library/Logs/${name}.log";
      env = lib.toUpper name;
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

        ProgramArguments = lib.ted.waitForNix (
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
