{
  config,
  pkgs,
  lib,
  mediaLaunch,
  ...
}:
let
  mountPoint = "/Volumes/media";
  export = "192.168.2.3:/volume1/media";

  inherit (config.launchd.daemons.nas-media.serviceConfig) Label;
  agents = config.launchd.user.agents;

  # Every service that uses the NAS starts through mediaLaunch
  mediaAgents =
    agents
    |> lib.filterAttrs (
      _: a:
      a.serviceConfig.ProgramArguments != null
      && lib.head a.serviceConfig.ProgramArguments == lib.head (mediaLaunch [ ])
    )
    |> lib.mapAttrsToList (_: a: a.serviceConfig.Label);

  # What stopping the services sets off. Anything else, like low disk space, still alerts.
  # healthchecks.nix also looks for this silence
  silencedAlerts = lib.concatStringsSep "|" [
    "ExporterDown"
    "JobFailing"
    "JobRestarting"
    "PublicSiteDown"
    "ServiceDown"
  ];
  silences = "http://127.0.0.1:9093/api/v2/silences";

  # The mount is hard, so anything using it while the NAS is off hangs until it's back.
  # start disconnects the services and unmounts the NAS; stop brings them back
  maintenance = pkgs.writeShellApplication {
    name = "nas-maintenance";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
    ];
    text = ''
      uid=$(id -u)
      # grep -q could exit early and fail the pipeline under pipefail
      mounted() { /sbin/mount | grep " on ${mountPoint} (nfs" > /dev/null; }
      loaded() { /bin/launchctl print "$1" > /dev/null 2>&1; }

      # bootout returns at once, and launchd keeps a job loaded until it has exited
      stopped() {
        for label in ${toString mediaAgents}; do
          if loaded "gui/$uid/$label"; then
            return 1
          fi
        done
      }

      silence_id() {
        /usr/bin/curl -fsS -m 5 ${silences} \
          | jq -r 'map(select(.createdBy == "nas-maintenance" and .status.state == "active")) | .[0].id // empty'
      }

      # Replaces the active silence, if any, so that reruns don't pile up
      silence_for() {
        local id
        id=$(silence_id) || return 1
        jq -n --arg id "$id" --arg start "$(date -u +%FT%TZ)" --arg end "$(date -u -d "$1" +%FT%TZ)" '{
          startsAt: $start,
          endsAt: $end,
          createdBy: "nas-maintenance",
          comment: "NAS maintenance",
          matchers: [{ name: "alertname", value: "${silencedAlerts}", isRegex: true, isEqual: true }]
        } + (if $id == "" then {} else { id: $id } end)' \
          | /usr/bin/curl -fsS -m 5 -H 'Content-Type: application/json' -d @- ${silences} > /dev/null
      }

      case "''${1:-}" in
        start)
          if /bin/launchctl print "gui/$uid/${agents.media-backup.serviceConfig.Label}" 2>/dev/null \
            | grep "state = running" > /dev/null; then
            echo "the nightly backup is running; try again once it finishes" >&2
            exit 1
          fi

          # Before anything stops, so that declining the prompt changes nothing
          if loaded system/${Label} || mounted; then
            sudo -v
          fi

          # Ends by itself in case 'stop' is forgotten
          if ! silence_for "4 hours"; then
            echo "couldn't silence alerts; carrying on" >&2
          fi

          for label in ${toString mediaAgents}; do
            if loaded "gui/$uid/$label"; then
              echo "stopping $label"
              /bin/launchctl bootout "gui/$uid/$label"
            fi
          done

          # Longer than any job's ExitTimeOut
          for _ in {1..90}; do
            stopped && break
            sleep 1
          done

          # Otherwise it remounts within 30s
          if loaded system/${Label}; then
            sudo /bin/launchctl bootout system/${Label}
          fi

          # launchd doesn't kill stragglers, which can hold the mount after their job is gone
          for _ in {1..60}; do
            mounted || break
            sudo /sbin/umount ${mountPoint} 2>/dev/null && break
            sleep 1
          done

          if mounted; then
            echo "still in use; stop these and run 'nas-maintenance start' again:" >&2
            /usr/sbin/lsof +f -- ${mountPoint} >&2 || true
            exit 1
          fi

          echo "${mountPoint} is unmounted; shut the NAS down, then run 'nas-maintenance stop' once it's back"
          ;;

        stop)
          if ! loaded system/${Label}; then
            sudo /bin/launchctl bootstrap system /Library/LaunchDaemons/${Label}.plist
          fi

          until mounted; do
            echo "waiting for ${mountPoint}"
            sleep 5
          done

          for label in ${toString mediaAgents}; do
            if ! loaded "gui/$uid/$label"; then
              echo "starting $label"
              /bin/launchctl bootstrap "gui/$uid" ~/Library/LaunchAgents/"$label".plist
            fi
          done

          # These keep running during maintenance and fail while Jellyfin is down. They only
          # run hourly, so without this JobFailing fires when the silence ends
          for _ in {1..60}; do
            /usr/bin/curl -fsS -m 2 -o /dev/null http://127.0.0.1:8096/health \
              && /usr/bin/curl -fsS -m 2 -o /dev/null http://127.0.0.1:8409/ \
              && break
            sleep 2
          done
          for label in ${agents.jellyfin-posters.serviceConfig.Label} ${agents.ersatztv-logos.serviceConfig.Label}; do
            /bin/launchctl kickstart "gui/$uid/$label" || echo "couldn't start $label" >&2
          done

          # Not ended outright, since firing alerts would go out while the services start
          if [ -n "$(silence_id || true)" ] && ! silence_for "10 minutes"; then
            echo "couldn't shorten the alert silence; it ends within 4 hours" >&2
          fi
          ;;

        *)
          echo "usage: nas-maintenance start|stop" >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home-manager.users.ted.home.packages = [ maintenance ];

  launchd.daemons.nas-media.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [
      "/bin/sh"
      "-c"
      ''
        /sbin/mount | grep -q " on ${mountPoint} (nfs" && exit 0
        mkdir -p ${mountPoint}
        # macOS defaults to 32K reads, so concurrent streams make the NAS's disks seek
        # between tiny reads; 128K is the most Synology's NFSv3 accepts. Readahead stays
        # at the default 16 RPCs (2 MiB), which still reads a file sequentially at
        # 60+ MB/s; the maximum 128 made qBittorrent's piece reads fetch ~4x the data
        /sbin/mount_nfs -o vers=3,tcp,hard,nfc,rsize=131072,wsize=131072 ${export} ${mountPoint}
      ''
    ];

    RunAtLoad = true;
    StandardErrorPath = "/var/log/nas-media.log";
    StandardOutPath = "/var/log/nas-media.log";
    StartInterval = 30;
  };
}
