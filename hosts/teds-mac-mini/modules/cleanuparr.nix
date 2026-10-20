{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/cleanuparr.log";

  cleanuparr = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "cleanuparr";
    version = "2.10.12";

    src = pkgs.fetchzip {
      url = "https://github.com/Cleanuparr/Cleanuparr/releases/download/v${version}/Cleanuparr-${version}-osx-arm64.zip";
      hash = "sha256-M01o0ZzAG/4ZvILT1G40Q8Qxrxp9HTxdhcUyINC0aWw=";
    };

    dontFixup = true;

    installPhase = ''
      mkdir -p $out/share
      cp -R . $out/share/cleanuparr
    '';
  };
in
{
  launchd.user.agents.cleanuparr.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    WorkingDirectory = "${cleanuparr}/share/cleanuparr";

    EnvironmentVariables = {
      BIND_ADDRESS = "127.0.0.1";
      PORT = "11011";
      CLEANUPARR_CONFIG_PATH = "/Users/ted/.local/share/cleanuparr";
    };

    ProgramArguments = lib.ted.waitForNix [ "${cleanuparr}/share/cleanuparr/Cleanuparr" ];
  };
}
