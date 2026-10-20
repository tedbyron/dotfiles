{ lib, ... }:
let
  mountPoint = "/Volumes/media";
  export = "192.168.2.3:/volume1/media";
in
{
  launchd.daemons.nas-media.serviceConfig = {
    ProgramArguments = lib.ted.waitForNix [
      "/bin/sh"
      "-c"
      ''
        /sbin/mount | grep -q " on ${mountPoint} (nfs" && exit 0
        mkdir -p ${mountPoint}
        /sbin/mount_nfs -o vers=3,tcp,hard,nfc ${export} ${mountPoint}
      ''
    ];

    RunAtLoad = true;
    StandardErrorPath = "/var/log/nas-media.log";
    StandardOutPath = "/var/log/nas-media.log";
    StartInterval = 30;
  };
}
