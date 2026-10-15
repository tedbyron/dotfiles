{ pkgs, ... }:
let
  log = "/Users/ted/Library/Logs/macos-process-exporter.log";

  macos-process-exporter = pkgs.buildGoModule rec {
    pname = "macos-process-exporter";
    version = "1.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "Digital-Shane";
      repo = "macos-process-exporter";
      rev = "v${version}";
      hash = "sha256-9uE4RQagII8hcXZGonJ7JAlkvU2+SJFHN1Mh7kcZNCw=";
    };

    vendorHash = "sha256-qzOezDBoeGvaZdUbGV52QksEb5cZ0JtSgERec64WVmg=";

    # BUG: gopsutil's cgo path pulls in go-m1cpu, which segfaults on init on M6
    env.CGO_ENABLED = 0;
  };
in
{
  launchd.user.agents.macos-process-exporter.serviceConfig = {
    KeepAlive = true;
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    ProgramArguments = [
      "${macos-process-exporter}/bin/macos-process-exporter"
      "--listen-address=127.0.0.1:9105"
      "--min-cpu-percent=0.1"
    ];
  };
}
