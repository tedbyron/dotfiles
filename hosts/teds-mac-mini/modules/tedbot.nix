{
  pkgs,
  lib,
  self,
  ...
}:
let
  # Discord token and API keys, copied from tedbot's config.toml; kept out of
  # the nix store
  configFile = "/Users/ted/.config/tedbot/config.toml";
  log = "/Users/ted/Library/Logs/tedbot.log";
  tedbot = self.inputs.tedbot.packages.${pkgs.stdenv.hostPlatform.system}.default;

  start = pkgs.writeShellScript "start-tedbot" ''
    until [ -s ${configFile} ]; do
      echo "waiting for ${configFile}"
      sleep 30
    done

    exec ${lib.getExe tedbot}
  '';
in
{
  launchd.user.agents.tedbot.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = lib.ted.waitForNix [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    ThrottleInterval = 30;

    EnvironmentVariables = {
      TEDBOT_CONFIG = configFile;
      # tracing_subscriber's default output is colored
      NO_COLOR = "1";
    };
  };
}
