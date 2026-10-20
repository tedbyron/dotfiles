{
  pkgs,
  lib,
  self,
  ...
}:
let
  log = "/Users/ted/Library/Logs/macos-process-exporter.log";
  src = self.inputs.macos-process-exporter;

  macos-process-exporter = pkgs.buildGoModule {
    pname = "macos-process-exporter";
    version = src.shortRev;
    inherit src;

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

    ProgramArguments = lib.ted.waitForNix [
      "${macos-process-exporter}/bin/macos-process-exporter"
      "--listen-address=127.0.0.1:9105"
      "--min-cpu-percent=0.1"
    ];
  };
}
