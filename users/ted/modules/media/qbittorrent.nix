{ pkgs, lib, ... }:
let
  tunnel = "mullvad";
  tunnelAddress = "10.75.150.82";
  proxy = "10.64.0.1";
  nameFile = "/var/run/wireguard/${tunnel}.name";
  log = "/Users/ted/Library/Logs/qbittorrent.log";
  ini = "/Users/ted/.config/qBittorrent/qBittorrent.ini";

  setInterface = pkgs.writeText "qbittorrent-interface.py" ''
    import sys

    path, iface, address = sys.argv[1:]
    wanted = {
        "Session\\Interface": iface,
        "Session\\InterfaceName": iface,
        "Session\\InterfaceAddress": address,
    }

    lines = open(path).read().splitlines()
    out, section, seen = [], None, set()
    for line in lines:
        if line.startswith("["):
            if section == "[BitTorrent]":
                out += [f"{k}={v}" for k, v in wanted.items() if k not in seen]
                seen.update(wanted)
            section = line.strip()
        elif section == "[BitTorrent]" and line.split("=", 1)[0] in wanted:
            key = line.split("=", 1)[0]
            line = f"{key}={wanted[key]}"
            seen.add(key)
        out.append(line)
    if section == "[BitTorrent]":
        out += [f"{k}={v}" for k, v in wanted.items() if k not in seen]
    elif "[BitTorrent]" not in lines:
        out += ["", "[BitTorrent]"] + [f"{k}={v}" for k, v in wanted.items()]

    open(path, "w").write("\n".join(out) + "\n")
  '';

  start = pkgs.writeShellScript "start-qbittorrent" ''
    until [ -d /Volumes/media/downloads ]; do
      echo "waiting for /Volumes/media"
      sleep 5
    done

    # wg-quick's name file is root-only, so find the interface by its address instead
    tunnel_iface() {
      /sbin/ifconfig | ${pkgs.gawk}/bin/awk '/^[a-z]/ { sub(":", "", $1); i = $1 } /inet ${tunnelAddress} / { print i }'
    }

    until [ -n "$(tunnel_iface)" ]; do
      echo "waiting for ${tunnel} tunnel"
      sleep 5
    done

    iface=$(tunnel_iface)
    echo "binding to $iface"
    ${pkgs.python3}/bin/python3 -I ${setInterface} ${ini} "$iface" ${tunnelAddress}

    ${lib.getExe pkgs.qbittorrent-nox} --confirm-legal-notice &
    pid=$!
    trap 'kill $pid; wait $pid' TERM INT

    while kill -0 $pid 2>/dev/null; do
      sleep 15
      if [ "$(tunnel_iface)" != "$iface" ]; then
        echo "${tunnel} tunnel changed or went down; stopping"
        kill $pid
        wait $pid
        exit 1
      fi
    done
    wait $pid
  '';
in
{
  networking.wg-quick.interfaces.${tunnel} = {
    address = [ "${tunnelAddress}/32" ];
    privateKeyFile = "/etc/wireguard/${tunnel}.key";
    table = "off";

    peers = [
      {
        publicKey = "kpXVJa66qgBFlwCmHx6siJT3R9afvtbjdDOTKkkbiUI=";
        endpoint = "23.234.85.2:51820";
        allowedIPs = [ "0.0.0.0/0" ];
        persistentKeepalive = 25;
      }
    ];

    postUp = ''
      iface=$(cat ${nameFile})
      /sbin/route -q -n add -inet default -interface "$iface" -ifscope "$iface"
      /sbin/route -q -n add -inet -host ${proxy} -interface "$iface"
    '';

    # The module's daemon never retries a failed `up` or restarts a dead tunnel
    autostart = false;
  };

  launchd.daemons."wg-quick-${tunnel}".serviceConfig = {
    EnvironmentVariables.PATH =
      lib.makeBinPath [
        pkgs.wireguard-go
        pkgs.wireguard-tools
      ]
      + ":/usr/bin:/bin:/usr/sbin:/sbin";

    ProgramArguments = [
      "/bin/sh"
      "-c"
      ''
        /sbin/ifconfig | grep -q "inet ${tunnelAddress} " \
          && /usr/bin/dig +time=5 +tries=3 @${proxy} mullvad.net > /dev/null \
          && exit 0
        wg-quick down ${tunnel} 2>/dev/null
        wg-quick up ${tunnel}
      ''
    ];

    RunAtLoad = true;
    StandardErrorPath = "/var/log/wg-quick-${tunnel}.log";
    StandardOutPath = "/var/log/wg-quick-${tunnel}.log";
    StartInterval = 30;
  };

  launchd.user.agents.qbittorrent.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    ThrottleInterval = 30;
  };
}
