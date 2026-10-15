{ pkgs, ... }:
let
  log = "/Users/ted/Library/Logs/opentamer.log";

  # Upstream's signed and notarized build; rules live in
  # ~/Library/Application Support/OpenTamer/config.json and are managed in the app
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

  # Started here instead of the app's "Launch at Login", which would register a store path
  launchd.user.agents.opentamer.serviceConfig = {
    KeepAlive = true;
    ProcessType = "Interactive";
    # Refuses to run unless launched through LaunchServices; -W blocks until it quits
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
