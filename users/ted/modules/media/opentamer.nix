{ pkgs, ... }:
let
  log = "/Users/ted/Library/Logs/opentamer.log";

  opentamer = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "opentamer";
    version = "1.4.1";

    src = pkgs.fetchurl {
      url = "https://github.com/Digital-Shane/OpenTamer/releases/download/v${version}/OpenTamer-${version}-macos-arm64.zip";
      hash = "sha256-72SyWeTIgf/dtJIvExG7Iq05Q3QVFGnh+aqvBlihtZw=";
    };

    nativeBuildInputs = [ pkgs.unzip ];
    sourceRoot = ".";
    dontFixup = true;

    installPhase = ''
      mkdir -p $out/Applications
      cp -R OpenTamer.app $out/Applications/
    '';
  };
in
{
  home-manager.users.ted.home.packages = [ opentamer ];

  launchd.user.agents.opentamer.serviceConfig = {
    KeepAlive = true;
    ProcessType = "Interactive";
    ProgramArguments = [
      "/usr/bin/open"
      "-W"
      "-g"
      "--stdout"
      log
      "--stderr"
      log
      "${opentamer}/Applications/OpenTamer.app"
    ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };
}
