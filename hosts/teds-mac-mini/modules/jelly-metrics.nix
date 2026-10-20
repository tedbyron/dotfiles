{
  pkgs,
  lib,
  self,
  ...
}:
let
  tokenFile = "/Users/ted/.config/jelly-metrics/token";
  log = "/Users/ted/Library/Logs/jelly-metrics.log";
  src = self.inputs.jelly-metrics;

  jelly-metrics = pkgs.buildGoModule {
    pname = "jelly-metrics";
    version = src.shortRev;
    inherit src;

    vendorHash = "sha256-mQ3sRIIsFXuoUZOZ42Mw2CM0wwJjt08cHPtOzbvOats=";

    postPatch = ''
      substituteInPlace main.go --replace-fail 'Addr:         ":" + port' 'Addr:         "127.0.0.1:" + port'
    '';
  };

  start = pkgs.writeShellScript "start-jelly-metrics" ''
    until [ -s ${tokenFile} ]; do
      echo "waiting for ${tokenFile}"
      sleep 30
    done

    JELLYFIN_TOKEN=$(< ${tokenFile})
    export JELLYFIN_TOKEN

    exec ${jelly-metrics}/bin/jelly-metrics
  '';
in
{
  launchd.user.agents.jelly-metrics.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    ThrottleInterval = 30;

    EnvironmentVariables = {
      JELLYFIN_HOST = "http://127.0.0.1:8096";
      PORT = "8097";
    };

    ProgramArguments = lib.ted.waitForNix [ "${start}" ];
  };
}
