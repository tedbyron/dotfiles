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

    # nas-maintenance's alert silence, so this has the same 4-hour limit. No API key
    # here to pause the check with, and it would come out of pause at the next ping
    in_maintenance() {
      /usr/bin/curl -fsS -m 5 http://127.0.0.1:9093/api/v2/silences \
        | ${lib.getExe pkgs.jq} -e 'any(.[]; .createdBy == "nas-maintenance" and .status.state == "active")' > /dev/null
    }

    if /usr/bin/curl -fsS -m 10 -o /dev/null https://stream.ted.ooo/health; then
      /usr/bin/curl -fsS -m 10 --retry 3 -o /dev/null "$url"
    elif in_maintenance; then
      echo "$(date) stream.ted.ooo/health failed during NAS maintenance"
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
