{ pkgs, lib, ... }:
let
  # macOS privacy settings charge a launchd job's file access to the first non-Apple
  # program it runs, even after that execs something else, and know an unsigned
  # program by its path and code hash. Started from the store, that's a different
  # program whenever bash or an app is updated, and its first NAS access then waits on
  # a prompt (holding up every other service's, too). Services that use the NAS start
  # through this instead, which stays put and is allowed only network volumes.
  path = "/usr/local/libexec/media-launch";
  src = ./media-launch.rs;
  launcher = pkgs.runCommandCC "media-launch" {
    nativeBuildInputs = [ pkgs.rustc ];
  } "rustc --edition 2024 -C opt-level=3 -C strip=symbols -o $out ${src}";
in
{
  _module.args.mediaLaunch = args: [ path ] ++ lib.ted.waitForNix args;

  # Replaced only when the source changes, since a rebuilt one has to be allowed again
  system.activationScripts.extraActivation.text = ''
    if ! cmp -s ${src} ${path}.rs; then
      mkdir -p ${dirOf path}
      install -m 755 ${launcher} ${path}
      /usr/bin/codesign --force --sign - --identifier ooo.ted.media-launch ${path}
      install -m 644 ${src} ${path}.rs
    fi
  '';
}
