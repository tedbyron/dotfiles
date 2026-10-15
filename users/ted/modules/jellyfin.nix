{ pkgs, ... }:
let
  mediaDir = "/Users/ted/media-test";
  dataDir = "/Users/ted/.local/share/jellyfin";
  cfgDir = "/Users/ted/.config/jellyfin";
  log = "/Users/ted/Library/Logs/jellyfin.log";

  networkXml = pkgs.writeText "network.xml" ''
    <?xml version="1.0" encoding="utf-8"?>
    <NetworkConfiguration xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
      <EnableRemoteAccess>true</EnableRemoteAccess>
      <KnownProxies>
        <string>127.0.0.1</string>
        <string>::1</string>
      </KnownProxies>
    </NetworkConfiguration>
  '';

  start = pkgs.writeShellScript "start-jellyfin" ''
    mkdir -p ${mediaDir} ${dataDir} ${cfgDir}

    until [ -d ${mediaDir} ]; do
      echo "waiting for ${mediaDir}"
      sleep 2
    done

    if [ ! -e ${cfgDir}/network.xml ]; then
      rm -f ${cfgDir}/network.xml
      ${pkgs.coreutils}/bin/install -m 644 ${networkXml} ${cfgDir}/network.xml
    fi

    if [ -e ${cfgDir}/system.xml ]; then
      ${pkgs.gnused}/bin/sed -i \
        's|<EnableMetrics>false</EnableMetrics>|<EnableMetrics>true</EnableMetrics>|' \
        ${cfgDir}/system.xml
    fi

    exec ${pkgs.jellyfin}/bin/jellyfin \
      --datadir ${dataDir} \
      --configdir ${cfgDir} \
      --cachedir ${dataDir}/cache \
      --logdir ${dataDir}/log
  '';
in
{
  launchd.user.agents.jellyfin.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
  };
}
