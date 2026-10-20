{ pkgs, ... }:
let
  log = "/Users/ted/Library/Logs/status-page.log";
in
{
  launchd.user.agents.status-page.serviceConfig = {
    ProgramArguments = [
      "${pkgs.python3}/bin/python3"
      "-I"
      "${./status-page/snapshot.py}"
      "/Users/ted/.local/share/status-page"
      "${./status-page/index.html}"
    ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    StartInterval = 300;
  };
}
