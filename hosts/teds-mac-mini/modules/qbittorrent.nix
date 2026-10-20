{ pkgs, lib, ... }:
let
  tunnel = "mullvad";
  tunnelAddress = "10.75.150.82";
  proxy = "10.64.0.1";

  # us-chi-wg-307; the account key and tunnel address work on any Mullvad server
  server = {
    publicKey = "U9UAYlVm8nXZjWPrF/vbb1P9oqSRmHo+IfK52yDYpGo=";
    endpoint = "68.235.46.188:51820";
  };
  nameFile = "/var/run/wireguard/${tunnel}.name";
  log = "/Users/ted/Library/Logs/qbittorrent.log";
  ini = "/Users/ted/.config/qBittorrent/qBittorrent.ini";

  # Applied on every start, overriding changes made in the web UI
  settings = {
    BitTorrent = {
      "Session\\DefaultSavePath" = "/Volumes/media/downloads";
      "Session\\TempPath" = "/Volumes/media/downloads/temp";
      "Session\\GlobalMaxRatio" = "2";
      "Session\\GlobalMaxSeedingMinutes" = "20160";
      "Session\\ShareLimitAction" = "RemoveWithContent";
      "Session\\AddTrackersFromURLEnabled" = "true";
      "Session\\AdditionalTrackersURL" =
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt";
      "Session\\AnnounceToAllTrackers" = "true";
    };
    # Mullvad's SOCKS5 proxy doesn't relay UDP on every server, which kills DHT and UDP trackers
    Network."Proxy\\Profiles\\BitTorrent" = "false";
  };

  setSettings = pkgs.writeText "qbittorrent-settings.py" ''
    import json, sys

    path, iface, address, settings = sys.argv[1:]
    wanted = json.loads(settings)
    wanted.setdefault("BitTorrent", {}).update({
        "Session\\Interface": iface,
        "Session\\InterfaceName": iface,
        "Session\\InterfaceAddress": address,
    })

    out, section, seen = [], None, set()

    def add_missing():
        for key, value in wanted.get(section, {}).items():
            if (section, key) not in seen:
                out.append(f"{key}={value}")
                seen.add((section, key))

    for line in open(path).read().splitlines():
        if line.startswith("["):
            add_missing()
            section = line.strip()[1:-1]
        elif line.split("=", 1)[0] in wanted.get(section, {}):
            key = line.split("=", 1)[0]
            line = f"{key}={wanted[section][key]}"
            seen.add((section, key))
        out.append(line)
    add_missing()

    for name, values in wanted.items():
        missing = [f"{k}={v}" for k, v in values.items() if (name, k) not in seen]
        if missing:
            out += ["", f"[{name}]"] + missing

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

    # A rebuilt tunnel can reuse the interface name, but qbittorrent's UDP socket stays on the old one
    tunnel_pid() {
      /usr/bin/pgrep -x wireguard-go
    }

    iface=$(tunnel_iface)
    wgpid=$(tunnel_pid)
    echo "binding to $iface"
    ${pkgs.python3}/bin/python3 -I ${setSettings} ${ini} "$iface" ${tunnelAddress} \
      ${lib.escapeShellArg (builtins.toJSON settings)}

    ${lib.getExe pkgs.qbittorrent-nox} --confirm-legal-notice &
    pid=$!
    trap 'kill $pid; wait $pid' TERM INT

    while kill -0 $pid 2>/dev/null; do
      sleep 15
      if [ "$(tunnel_iface)" != "$iface" ] || [ "$(tunnel_pid)" != "$wgpid" ]; then
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
        inherit (server) publicKey endpoint;
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
          && wg show "$(cat ${nameFile})" peers | grep -qxF ${lib.escapeShellArg server.publicKey} \
          && /usr/bin/dig +time=5 +tries=3 @${proxy} mullvad.net > /dev/null \
          && exit 0
        wg-quick down ${tunnel} 2>/dev/null
        wg-quick up ${tunnel}
      ''
    ];

    # wireguard-go keeps running after this check exits
    AbandonProcessGroup = true;
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
