{ pkgs, lib, ... }:
let
  home = "/Users/ted/.local/share/flaresolverr";
  log = "/Users/ted/Library/Logs/flaresolverr.log";

  # Chrome can't resolve its user data dir under the real ~/Library ("Failed to get the path for
  # 1001"), so give it a private home; this also keeps its throwaway profiles out of ~/Library
  chrome = pkgs.writeShellScriptBin "chrome" ''
    export CFFIXED_USER_HOME=${home}
    exec "${pkgs.google-chrome}/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" "$@"
  '';

  # Patching invalidates Google's code signature, and Apple Silicon kills unsigned binaries
  undetected-chromedriver = pkgs.undetected-chromedriver.overrideAttrs (old: {
    buildCommand = old.buildCommand + ''
      chmod u+w $out/bin/undetected-chromedriver
      ${pkgs.darwin.sigtool}/bin/codesign -f -s - $out/bin/undetected-chromedriver
      chmod u-w $out/bin/undetected-chromedriver
    '';
  });

  flaresolverr = pkgs.flaresolverr.override {
    chromium = chrome;
    inherit undetected-chromedriver;
  };
in
{
  launchd.user.agents.flaresolverr.serviceConfig = {
    KeepAlive = true;
    ProgramArguments = [
      "/bin/sh"
      "-c"
      "mkdir -p ${home} && exec ${lib.getExe flaresolverr}"
    ];
    RunAtLoad = true;
    StandardErrorPath = log;
    StandardOutPath = log;

    EnvironmentVariables = {
      HEADLESS = "true";
      HOST = "127.0.0.1";
      PORT = "8191";
    };
  };
}
