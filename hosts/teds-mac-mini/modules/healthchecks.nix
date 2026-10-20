{ pkgs, lib, ... }:
let
  urlFile = "/Users/ted/.config/healthchecks/ping-url";
  log = "/Users/ted/Library/Logs/healthchecks.log";

  ping = pkgs.writeShellScript "healthchecks-ping" ''
    if [ ! -s ${urlFile} ]; then
      echo "missing ${urlFile}"
      exit 0
    fi
    url=$(< ${urlFile})

    if /usr/bin/curl -fsS -m 10 -o /dev/null https://stream.ted.ooo/health; then
      /usr/bin/curl -fsS -m 10 --retry 3 -o /dev/null "$url"
    else
      echo "$(date) stream.ted.ooo/health failed"
      /usr/bin/curl -fsS -m 10 --retry 3 -o /dev/null "$url/fail"
    fi
  '';
in
{
  launchd.user.agents.healthchecks.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [ "${ping}" ];
    RunAtLoad = true;
    StartInterval = 600;
    StandardErrorPath = log;
    StandardOutPath = log;
  };
}
