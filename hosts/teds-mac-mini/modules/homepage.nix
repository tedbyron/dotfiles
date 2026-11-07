{
  pkgs,
  lib,
  unstable,
  ...
}:
let
  port = 8410;
  share = "/Users/ted/.local/share";
  cache = "/Users/ted/Library/Caches/homepage";
  log = "/Users/ted/Library/Logs/homepage.log";

  yaml = pkgs.formats.yaml { };
  prometheus = "http://127.0.0.1:9090";

  # Internal services bind to 127.0.0.1, so their cards have no links, only a
  # status dot from Homepage's own request to the same URL Prometheus probes
  monitor = name: icon: siteMonitor: { ${name} = { inherit icon siteMonitor; }; };

  # var names the HOMEPAGE_VAR_* the start script exports the key in
  # More than three fields overflow a card at four columns
  arr = type: fields: name: var: port': {
    ${name} = {
      icon = "${type}.svg";
      siteMonitor = "http://127.0.0.1:${toString port'}/ping";
      widget = {
        inherit type fields;
        url = "http://127.0.0.1:${toString port'}";
        key = "{{HOMEPAGE_VAR_${var}}}";
      };
    };
  };

  sonarr = [
    "wanted"
    "queued"
    "series"
  ];
  radarr = [
    "missing"
    "queued"
    "movies"
  ];
  prowlarr = [
    "numberOfGrabs"
    "numberOfQueries"
    "numberOfFailQueries"
  ];

  bazarr = name: var: port': {
    ${name} = {
      icon = "bazarr.svg";
      siteMonitor = "http://127.0.0.1:${toString port'}/";
      widget = {
        type = "bazarr";
        url = "http://127.0.0.1:${toString port'}";
        key = "{{HOMEPAGE_VAR_${var}}}";
      };
    };
  };

  # Free space as "free / total" and as a percentage. A metric is one number,
  # so the total is fixed text: df's size for each volume, which only changes
  # with new drives
  disk =
    name: mountpoint: total:
    let
      volume = ''{mountpoint="${mountpoint}"}'';
    in
    [
      {
        key = "${name}-free";
        label = "${name} free";
        query = "node_filesystem_avail_bytes${volume}";
        format = {
          type = "bytes";
          suffix = " / ${total}";
        };
      }
      {
        key = "${name}-percent";
        label = "${name} free";
        query = "node_filesystem_avail_bytes${volume} / node_filesystem_size_bytes${volume} * 100";
        format = {
          type = "percent";
          options.maximumFractionDigits = 0;
        };
      }
    ];

  settings = {
    title = "ted.ooo";
    favicon = "https://tedbyron.com/favicon.png";
    theme = "dark";
    color = "stone";
    headerStyle = "clean";
    statusStyle = "dot";
    hideVersion = true;
    disableUpdateCheck = true;
    useEqualHeights = true;
    # A list keeps this order; YAML from an attrset would sort the groups
    layout = [
      {
        Public = {
          style = "row";
          columns = 3;
        };
      }
      {
        Server = {
          style = "row";
          columns = 3;
        };
      }
      {
        Media = {
          style = "row";
          columns = 4;
        };
      }
      {
        Other = {
          style = "row";
          columns = 5;
        };
      }
    ];
  };

  widgets = [
    {
      resources = {
        label = "Mac mini";
        cpu = true;
        memory = true;
        uptime = true;
      };
    }
    {
      datetime = {
        text_size = "md";
        format = {
          dateStyle = "medium";
          timeStyle = "short";
        };
      };
    }
  ];

  services = [
    {
      Public = [
        {
          "stream.ted.ooo" = {
            icon = "jellyfin.svg";
            href = "https://stream.ted.ooo";
            siteMonitor = "https://stream.ted.ooo/health";
            widget = {
              type = "jellyfin";
              url = "http://127.0.0.1:8096";
              key = "{{HOMEPAGE_VAR_JELLYFIN}}";
              version = 2;
              enableBlocks = true;
              enableNowPlaying = true;
              enableMediaControl = false;
              showEpisodeNumber = true;
              expandOneStreamToTwoRows = false;
              fields = [
                "movies"
                "series"
                "episodes"
              ];
            };
          };
        }
        {
          "request.ted.ooo" = {
            icon = "jellyseerr.svg";
            href = "https://request.ted.ooo";
            siteMonitor = "https://request.ted.ooo/api/v1/status";
            widget = {
              type = "seerr";
              url = "http://127.0.0.1:5055";
              key = "{{HOMEPAGE_VAR_SEERR}}";
              fields = [
                "pending"
                "processing"
                "issues"
              ];
            };
          };
        }
        {
          # healthchecks.nix pings it every 10 minutes while stream.ted.ooo
          # answers, so this is the outside view of the mini
          "healthchecks.io" = {
            icon = "healthchecks.svg";
            href = "https://healthchecks.io";
            widget = {
              type = "healthchecks";
              url = "https://healthchecks.io";
              key = "{{HOMEPAGE_VAR_HEALTHCHECKS}}";
              # The check's read-only ID, not its ping UUID
              uuid = "41ca798e441ffbbf146c613551232a787cc84921";
            };
          };
        }
      ];
    }
    {
      Server = [
        {
          Uptime = {
            icon = "prometheus.svg";
            widget = {
              type = "prometheusmetric";
              url = prometheus;
              refreshInterval = 60000;
              metrics = [
                {
                  label = "stream 30d";
                  query = ''avg_over_time(probe_success{instance="https://stream.ted.ooo/health"}[30d]) * 100'';
                  format = {
                    type = "percent";
                    options.maximumFractionDigits = 2;
                  };
                }
                {
                  label = "request 30d";
                  query = ''avg_over_time(probe_success{instance="https://request.ted.ooo/api/v1/status"}[30d]) * 100'';
                  format = {
                    type = "percent";
                    options.maximumFractionDigits = 2;
                  };
                }
                {
                  label = "Services up";
                  query = ''sum(probe_success{job="services"})'';
                }
                {
                  label = "Alerts";
                  query = ''count(ALERTS{alertstate="firing", alertname!="JellyfinRestartPending"}) or vector(0)'';
                }
              ];
            };
          };
        }
        {
          Storage = {
            icon = "synology.svg";
            widget = {
              type = "prometheusmetric";
              url = prometheus;
              refreshInterval = 300000;
              metrics = disk "NAS" "/Volumes/media" "21.1 TB" ++ disk "mini" "/System/Volumes/Data" "245 GB";
            };
          };
        }
        {
          Network = {
            icon = "mdi-swap-vertical-#d4be98";
            widget = {
              type = "prometheusmetric";
              url = prometheus;
              refreshInterval = 30000;
              metrics =
                let
                  rate = label: query: {
                    inherit label query;
                    format.type = "byterate";
                  };
                in
                [
                  # wg-quick picks the utun number at start, and the other utuns
                  # (iCloud, NextDNS) carry next to nothing, so the busiest is
                  # the tunnel
                  (rate "VPN down" ''max(rate(node_network_receive_bytes_total{device=~"utun.*"}[2m]))'')
                  (rate "VPN up" ''max(rate(node_network_transmit_bytes_total{device=~"utun.*"}[2m]))'')
                  # Includes NFS to the NAS and the tunnel's own packets
                  (rate "LAN in" ''rate(node_network_receive_bytes_total{device="en0"}[2m])'')
                  (rate "LAN out" ''rate(node_network_transmit_bytes_total{device="en0"}[2m])'')
                ];
            };
          };
        }
        {
          Alerts = {
            icon = "alertmanager.svg";
            # Alertmanager rather than Prometheus: it has the rendered
            # summaries and leaves out silenced alerts (nas-maintenance)
            widget = {
              type = "customapi";
              url = "http://127.0.0.1:9093/api/v2/alerts?active=true&silenced=false&inhibited=false&filter=${lib.escapeURL ''alertname!="JellyfinRestartPending"''}";
              refreshInterval = 60000;
              display = "dynamic-list";
              mappings = {
                name = "annotations.summary";
                label = "startsAt";
                format = "relativeDate";
                limit = 6;
              };
            };
          };
        }
        {
          Backup = {
            # Material Design Icon, tinted the page's text color
            icon = "mdi-backup-restore-#d4be98";
            # Written by backup.nix when an archive reaches the NAS; a failed
            # run also shows as JobFailing under Alerts
            widget = {
              type = "prometheusmetric";
              url = prometheus;
              refreshInterval = 300000;
              metrics = [
                {
                  label = "Last backup";
                  query = "media_backup_last_success_timestamp_seconds";
                  format = {
                    type = "relativeDate";
                    scale = 1000;
                  };
                }
                {
                  label = "Size";
                  query = "media_backup_size_bytes";
                  format.type = "bytes";
                }
              ];
            };
          };
        }
        {
          Releases = {
            icon = "sonarr.svg";
            widget = {
              type = "calendar";
              view = "agenda";
              maxEvents = 8;
              showTime = true;
              integrations = [
                {
                  type = "sonarr";
                  service_group = "Media";
                  service_name = "Sonarr";
                }
                {
                  type = "radarr";
                  service_group = "Media";
                  service_name = "Radarr";
                }
              ];
            };
          };
        }
      ];
    }
    {
      Media = [
        (arr "radarr" radarr "Radarr" "RADARR" 7878)
        (arr "radarr" radarr "Radarr 4K" "RADARR_4K" 7879)
        (arr "sonarr" sonarr "Sonarr" "SONARR" 8989)
        (arr "sonarr" sonarr "Sonarr 4K" "SONARR_4K" 8990)
        (arr "prowlarr" prowlarr "Prowlarr" "PROWLARR" 9696)
        (bazarr "Bazarr" "BAZARR" 6767)
        (bazarr "Bazarr 4K" "BAZARR_4K" 6768)
        {
          qBittorrent = {
            icon = "qbittorrent.svg";
            siteMonitor = "http://127.0.0.1:8080/";
            widget = {
              type = "qbittorrent";
              url = "http://127.0.0.1:8080";
              username = "{{HOMEPAGE_VAR_QBITTORRENT_USER}}";
              password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
            };
          };
        }
      ];
    }
    {
      Other = [
        (monitor "ErsatzTV" "ersatztv.svg" "http://127.0.0.1:8409/")
        (monitor "Cleanuparr" "cleanuparr.png" "http://127.0.0.1:11011/health")
        (monitor "FlareSolverr" "flaresolverr.svg" "http://127.0.0.1:8191/")
        (monitor "Grafana" "grafana.svg" "http://127.0.0.1:3000/api/health")
        (monitor "tedbot" "discord.svg" "http://127.0.0.1:5056/health")
      ];
    }
  ];

  # A widget's fields list only picks which blocks show; they render in the
  # widget's own order. reorder <service> <new position of each block, in
  # the widget's order> moves them with flex order
  reorder =
    service: positions:
    lib.concatImapStrings (i: order: ''
      li.service[data-name="${service}"] .service-container > .service-block:nth-child(${toString i}) {
        order: ${toString order};
      }
    '') positions;

  customCSS = lib.concatStrings [
    # Gruvbox Material dark, as the old status page and the Firefox theme
    # (config/firefox): Homepage's palette is 50 (lightest) to 900, as RGB
    # triplets; dark mode uses 800 for the page and 200 for text. More
    # specific than Homepage's own .theme-stone
    ''
      html.theme-stone {
        --color-50: 251 241 199;
        --color-100: 242 229 188;
        --color-200: 221 199 161;
        --color-300: 212 190 152;
        --color-400: 168 153 132;
        --color-500: 146 131 116;
        --color-600: 124 111 100;
        --color-700: 69 64 61;
        --color-800: 40 40 40;
        --color-900: 29 32 33;
        --color-logo-start: 231 138 78;
        --color-logo-stop: 216 166 87;
        --color-emerald-500: #a9b665;
        --color-rose-500: #ea6962;
        --color-red-500: #ea6962;
        --color-amber-500: #d8a657;
        --color-orange-500: #e78a4e;
        --color-teal-500: #89b482;
      }
    ''
    # leech, download, seed, upload -> leech, seed, download, upload. It and
    # Storage are two rows of two, since their values don't fit four across
    (reorder "qBittorrent" [
      1
      3
      2
      4
    ])
    # The alert list's empty state says "No items found"
    ''
      li.service[data-name="Alerts"] div:not(.animate-pulse) > .font-thin:only-child {
        font-size: 0;
      }
      li.service[data-name="Alerts"] div:not(.animate-pulse) > .font-thin:only-child::after {
        content: "No firing alerts";
        font-size: 0.75rem;
      }
    ''
    ''
      li.service:is([data-name="qBittorrent"], [data-name="Storage"]) .service-container {
        flex-wrap: wrap;
      }
      li.service:is([data-name="qBittorrent"], [data-name="Storage"]) .service-block {
        flex-basis: calc(50% - 0.5rem);
      }
    ''
  ];

  # Homepage copies its skeleton into the config directory for any file
  # missing there, which would fail in the store
  config = pkgs.linkFarm "homepage-config" {
    "settings.yaml" = yaml.generate "settings.yaml" settings;
    "widgets.yaml" = yaml.generate "widgets.yaml" widgets;
    "services.yaml" = yaml.generate "services.yaml" services;
    "bookmarks.yaml" = yaml.generate "bookmarks.yaml" [ ];
    "docker.yaml" = yaml.generate "docker.yaml" { };
    "kubernetes.yaml" = yaml.generate "kubernetes.yaml" { };
    "proxmox.yaml" = yaml.generate "proxmox.yaml" { };
    "custom.css" = pkgs.writeText "custom.css" customCSS;
    # Browsers tint their toolbar (and Safari its tab bar) from theme-color,
    # which Homepage sets from its own palette, not custom.css. It replaces
    # the tag after this runs, so keep correcting it
    "custom.js" = pkgs.writeText "custom.js" ''
      const fixThemeColor = () => {
        for (const meta of document.querySelectorAll(
          'meta[name="theme-color"], meta[name="msapplication-TileColor"]',
        )) {
          if (meta.content !== "#282828") meta.content = "#282828";
        }
      };
      fixThemeColor();
      new MutationObserver(fixThemeColor).observe(document.head, {
        subtree: true,
        childList: true,
        attributes: true,
        attributeFilter: ["content"],
      });
    '';
  };

  # API keys stay out of the store; Homepage fills {{HOMEPAGE_VAR_*}} from these
  start = pkgs.writeShellScript "start-homepage" ''
    arr_key() {
      ${lib.getExe pkgs.gnused} -n 's:.*<ApiKey>\(.*\)</ApiKey>.*:\1:p' "${share}/$1/config.xml"
    }
    bazarr_key() {
      ${lib.getExe pkgs.yq-go} '.auth.apikey' "${share}/$1/config/config.yaml"
    }

    export HOMEPAGE_VAR_SONARR=$(arr_key sonarr)
    export HOMEPAGE_VAR_SONARR_4K=$(arr_key sonarr-4k)
    export HOMEPAGE_VAR_RADARR=$(arr_key radarr)
    export HOMEPAGE_VAR_RADARR_4K=$(arr_key radarr-4k)
    export HOMEPAGE_VAR_PROWLARR=$(arr_key prowlarr)
    export HOMEPAGE_VAR_BAZARR=$(bazarr_key bazarr)
    export HOMEPAGE_VAR_BAZARR_4K=$(bazarr_key bazarr-4k)
    export HOMEPAGE_VAR_SEERR=$(${lib.getExe pkgs.jq} -r .main.apiKey "${share}/seerr/settings.json")
    export HOMEPAGE_VAR_JELLYFIN=$(< /Users/ted/.config/jelly-metrics/token)
    # Read-only key
    export HOMEPAGE_VAR_HEALTHCHECKS=$(< /Users/ted/.config/healthchecks/api-key)
    # The WebUI login is only stored hashed in qBittorrent's own config, so take
    # it from Radarr's download client
    qbittorrent=$(${lib.getExe pkgs.sqlite} -readonly "${share}/radarr/radarr.db" \
      "select Settings from DownloadClients where Implementation = 'QBittorrent' limit 1")
    export HOMEPAGE_VAR_QBITTORRENT_USER=$(${lib.getExe pkgs.jq} -r .username <<< "$qbittorrent")
    export HOMEPAGE_VAR_QBITTORRENT_PASSWORD=$(${lib.getExe pkgs.jq} -r .password <<< "$qbittorrent")

    # Next.js's prerender cache survives upgrades and breaks the new version
    rm -rf "${cache}"
    mkdir -p "${cache}"

    exec ${lib.getExe unstable.homepage-dashboard}
  '';
in
{
  launchd.user.agents.homepage.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = lib.ted.waitForNix [ "${start}" ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;
    ThrottleInterval = 30;

    EnvironmentVariables = {
      PORT = toString port;
      HOSTNAME = "127.0.0.1";
      HOMEPAGE_CONFIG_DIR = "${config}";
      NIXPKGS_HOMEPAGE_CACHE_DIR = cache;
      HOMEPAGE_ALLOWED_HOSTS = "status.ted.ooo";
      LOG_TARGETS = "stdout";
      NEXT_TELEMETRY_DISABLED = "1";
    };
  };
}
