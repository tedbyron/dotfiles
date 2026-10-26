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

  # The mount is hard, so anything using it while the NAS is off hangs until it's back.
  # start disconnects the services and unmounts the NAS; stop brings them back
  maintenance = pkgs.writeShellApplication {
    name = "nas-maintenance";
    text = ''
      uid=$(id -u)
      # grep -q could exit early and fail the pipeline under pipefail
      mounted() { /sbin/mount | grep " on ${mountPoint} (nfs" > /dev/null; }
      loaded() { /bin/launchctl print "$1" > /dev/null 2>&1; }

      case "''${1:-}" in
        start)
          if /bin/launchctl print "gui/$uid/${agents.media-backup.serviceConfig.Label}" 2>/dev/null \
            | grep "state = running" > /dev/null; then
            echo "the nightly backup is running; try again once it finishes" >&2
            exit 1
          fi

          for label in ${toString mediaAgents}; do
            if loaded "gui/$uid/$label"; then
              echo "stopping $label"
              /bin/launchctl bootout "gui/$uid/$label"
            fi
          done

          # Otherwise it remounts within 30s
          if loaded system/${Label}; then
            sudo /bin/launchctl bootout system/${Label}
          fi

          if mounted && ! sudo /sbin/umount ${mountPoint}; then
            echo "still in use:" >&2
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
