{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/status-page.log";
in
{
  launchd.user.agents.status-page.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = lib.ted.waitForNix [
      "${pkgs.python3}/bin/python3"
      "-I"
      "${./status-page/server.py}"
      "8410"
      "${./status-page/index.html}"
    ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };
}
