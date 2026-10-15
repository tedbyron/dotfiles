{ pkgs, lib, ... }:
let
  services = {
    prowlarr = {
      package = pkgs.prowlarr;
      port = 9696;
      allowedHosts = true;
    };
    radarr = {
      package = pkgs.radarr;
      port = 7878;
      allowedHosts = true;
    };
    sonarr = {
      package = pkgs.sonarr;
      port = 8989;
      allowedHosts = false;
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

        ProgramArguments = [
          (lib.getExe package)
          "-nobrowser"
          "-data=/Users/ted/.local/share/${name}"
        ];
      };
    }
  ) services;
}
