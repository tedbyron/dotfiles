{ pkgs, ... }:
let
  log = "/Users/ted/Library/Logs/caddy.log";

  caddyfile = pkgs.writeText "Caddyfile" ''
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

    stream.ted.ooo {
      import security
      @metrics path /metrics*
      respond @metrics 403
      reverse_proxy 127.0.0.1:8096
    }

    request.ted.ooo {
      import security
      reverse_proxy 127.0.0.1:5055
    }

    # Static files written by status-page.nix; nothing else is served
    status.ted.ooo {
      import security
      @files path / /index.html /status.json /calendar.ics
      handle @files {
        root * /Users/ted/.local/share/status-page
        header /status.json Cache-Control "no-cache"
        header /calendar.ics Content-Type "text/calendar; charset=utf-8"
        file_server
      }
      respond 404
    }
  '';
in
{
  launchd.user.agents.caddy.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = [
      "${pkgs.caddy}/bin/caddy"
      "run"
      "--config"
      "${caddyfile}"
      "--adapter"
      "caddyfile"
    ];
  };
}
