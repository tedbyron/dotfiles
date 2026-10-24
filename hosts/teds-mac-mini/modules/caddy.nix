{ pkgs, lib, ... }:
let
  log = "/Users/ted/Library/Logs/caddy.log";

  caddy = pkgs.caddy.withPlugins {
    plugins = [ "github.com/mholt/caddy-ratelimit@v0.1.1-0.20260612195517-5625512f24f6" ];
    hash = "sha256-un3EYnFin5o/HrW7yZlVTMWzWbYYNbL7wjuhWb37CC8=";
  };

  # From https://www.cloudflare.com/ips-v4 and ips-v6
  cloudflare = lib.concatStringsSep " " [
    "173.245.48.0/20"
    "103.21.244.0/22"
    "103.22.200.0/22"
    "103.31.4.0/22"
    "141.101.64.0/18"
    "108.162.192.0/18"
    "190.93.240.0/20"
    "188.114.96.0/20"
    "197.234.240.0/22"
    "198.41.128.0/17"
    "162.158.0.0/15"
    "104.16.0.0/13"
    "104.24.0.0/14"
    "172.64.0.0/13"
    "131.0.72.0/22"
    "2400:cb00::/32"
    "2606:4700::/32"
    "2803:f800::/32"
    "2405:b500::/32"
    "2405:8100::/32"
    "2a06:98c0::/29"
    "2c0f:f248::/32"
  ];

  caddyfile = pkgs.writeText "Caddyfile" ''
    {
      order rate_limit before basic_auth
      # request. and status. are proxied by Cloudflare; stream. isn't, so its clients connect directly
      servers {
        trusted_proxies static ${cloudflare}
        client_ip_headers CF-Connecting-IP
      }
    }

    (security) {
      header {
        Strict-Transport-Security "max-age=31536000"
        X-Content-Type-Options "nosniff"
        X-Frame-Options "SAMEORIGIN"
        Referrer-Policy "strict-origin-when-cross-origin"
        -Server
        defer
      }
    }

    # Sites proxied by Cloudflare refuse connections that skip it
    (cloudflare) {
      @direct not remote_ip ${cloudflare}
      abort @direct
    }

    # import limit <zone> <events> <window> <paths...>, per client IP; over it gets a 429 with Retry-After
    (limit) {
      rate_limit {
        zone {args[0]} {
          match {
            path {args[3:]}
          }
          key {client_ip}
          events {args[1]}
          window {args[2]}
        }
      }
    }

    # No limit on everything else: browsing loads hundreds of images and a household shares one IP
    stream.ted.ooo {
      import security
      import limit jellyfin-login 10 5m */Users/AuthenticateByName */Users/AuthenticateWithQuickConnect */QuickConnect/Initiate */Users/ForgotPassword*
      @metrics path /metrics*
      respond @metrics 403
      reverse_proxy 127.0.0.1:8096
    }

    request.ted.ooo {
      import security
      import cloudflare
      # Not all of /api/v1/auth/*: the app checks /me on most page changes and
      # polls quickconnect/check while waiting
      import limit seerr-login 10 5m /api/v1/auth/jellyfin /api/v1/auth/jellyfin/quickconnect/initiate /api/v1/auth/jellyfin/quickconnect/authenticate /api/v1/auth/local /api/v1/auth/plex /api/v1/auth/reset-password*
      # Browsing and requesting while signed in passed 600/min: every card and
      # request fetches its own title and avatar, and a household shares one IP
      import limit seerr 3000 1m *
      # Seerr trusts the leftmost X-Forwarded-For, which Cloudflare passes
      # through from the client
      reverse_proxy 127.0.0.1:5055 {
        header_up X-Forwarded-For {client_ip}
      }
    }

    # status-page.nix; nothing else is served
    status.ted.ooo {
      import security
      import cloudflare
      import limit status 60 1m *
      @other not path / /index.html /status.json /calendar.ics /health
      respond @other 404
      reverse_proxy 127.0.0.1:8410
    }
  '';
in
{
  launchd.user.agents.caddy.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = lib.ted.waitForNix [
      "${caddy}/bin/caddy"
      "run"
      "--config"
      "${caddyfile}"
      "--adapter"
      "caddyfile"
    ];
  };
}
