{ pkgs, lib, ... }:
let
  dataDir = "/Users/ted/.local/share/seerr";
  log = "/Users/ted/Library/Logs/seerr.log";

  seerr = pkgs.seerr.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [
      pkgs.cctools
      pkgs.xcbuild
    ];

    meta = old.meta // {
      platforms = lib.platforms.unix;
    };
  });
in
{
  launchd.user.agents.seerr.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ (lib.getExe seerr) ];
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
