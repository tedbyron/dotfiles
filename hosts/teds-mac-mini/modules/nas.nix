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
