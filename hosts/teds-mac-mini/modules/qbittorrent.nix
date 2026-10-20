{ pkgs, lib, ... }:
let
  tunnel = "proton";
  # Every Proton WireGuard config uses this address; the gateway is also its DNS and NAT-PMP server
  tunnelAddress = "10.2.0.2";
  gateway = "10.2.0.1";

  # US-OH#8, a P2P server, from a WireGuard config generated with NAT-PMP (Port Forwarding) on
  server = {
    publicKey = "Rtsl6k9WA9t04Vt+EDUD3TlSr9+YL6YcTFwiSB1qBwA=";
    endpoint = "146.70.84.2:51820";
  };
  nameFile = "/var/run/wireguard/${tunnel}.name";
  log = "/Users/ted/Library/Logs/qbittorrent.log";
  ini = "/Users/ted/.config/qBittorrent/qBittorrent.ini";

  # natpmpc links its own library by bare name, so dyld can't find it on macOS
  natpmpc = "${
    pkgs.libnatpmp.overrideAttrs {
      postFixup = "install_name_tool -change libnatpmp.1.dylib $out/lib/libnatpmp.1.dylib $out/bin/natpmpc";
    }
  }/bin/natpmpc";

  # Applied on every start, overriding changes made in the web UI
  settings = {
    BitTorrent = {
      "Session\\DefaultSavePath" = "/Volumes/media/downloads";
      "Session\\GlobalMaxRatio" = "2";
      "Session\\GlobalMaxSeedingMinutes" = "20160";
      # Radarr and Sonarr remove stopped torrents once they've imported them
      "Session\\ShareLimitAction" = "Stop";
      "Session\\AddTrackersFromURLEnabled" = "true";
      "Session\\AdditionalTrackersURL" =
        "https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_best.txt";
      "Session\\AnnounceToAllTrackers" = "true";
    };
    Network."Proxy\\Type" = "None";
  };

  setSettings = pkgs.writeText "qbittorrent-settings.py" ''
    import json, sys

    path, iface, address, port, settings = sys.argv[1:]
    wanted = json.loads(settings)
    wanted.setdefault("BitTorrent", {}).update({
        "Session\\Interface": iface,
        "Session\\InterfaceName": iface,
        "Session\\InterfaceAddress": address,
    })
    if port:
        wanted["BitTorrent"]["Session\\Port"] = port

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

    # Proton keeps a forwarded port only while it's renewed within its 60s lifetime
    forward_port() {
      ${natpmpc} -g ${gateway} -a 1 0 udp 60 > /dev/null \
        && ${natpmpc} -g ${gateway} -a 1 0 tcp 60 \
        | ${lib.getExe pkgs.gnused} -n 's/^Mapped public port \([0-9]*\) protocol TCP.*/\1/p'
    }

    iface=$(tunnel_iface)
    wgpid=$(tunnel_pid)
    port=$(forward_port)
    if [ -n "$port" ]; then
      echo "binding to $iface, port $port"
    else
      echo "binding to $iface; no forwarded port, so peers can't connect in"
    fi
    ${pkgs.python3}/bin/python3 -I ${setSettings} ${ini} "$iface" ${tunnelAddress} "$port" \
      ${lib.escapeShellArg (builtins.toJSON settings)}

    ${lib.getExe pkgs.qbittorrent-nox} --confirm-legal-notice &
    pid=$!
    trap 'kill $pid; wait $pid' TERM INT

    stop() {
      echo "$1; stopping"
      kill $pid
      wait $pid
      exit 1
    }

    while kill -0 $pid 2>/dev/null; do
      sleep 15
      if [ "$(tunnel_iface)" != "$iface" ] || [ "$(tunnel_pid)" != "$wgpid" ]; then
        stop "${tunnel} tunnel changed or went down"
      fi

      renewed=$(forward_port)
      if [ -n "$renewed" ] && [ "$renewed" != "$port" ]; then
        stop "forwarded port changed from ''${port:-none} to $renewed"
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
      /sbin/route -q -n add -inet -host ${gateway} -interface "$iface"
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
          && /usr/bin/dig +time=5 +tries=3 @${gateway} protonvpn.com > /dev/null \
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
