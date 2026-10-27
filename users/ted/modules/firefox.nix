{
  config,
  lib,
  pkgs,
  darwin,
  ...
}:
let
  home = config.home.homeDirectory;
  firefoxDir =
    if darwin then "${home}/Library/Application Support/Firefox" else "${home}/.mozilla/firefox";
  zenDir = if darwin then "${home}/Library/Application Support/zen" else "${home}/.zen";

  # Signed by addons.mozilla.org (unlisted) from config/firefox/gruvbox-theme;
  # bump the version and re-sign after changing it.
  theme = lib.ted.configPath "firefox/gruvbox-theme.xpi";
  themeId =
    (lib.importJSON (lib.ted.configPath "firefox/gruvbox-theme/manifest.json"))
    .browser_specific_settings.gecko.id;
in
{
  # Copy the theme into each install's default profile. It starts disabled;
  # enable it once in about:addons.
  home.activation.firefoxProfiles = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    default_profiles() {
      [ -f "$1/profiles.ini" ] || return 0
      ${lib.getExe pkgs.gawk} -F= '/^\[Install/ { i = 1; next } /^\[/ { i = 0 } i && $1 == "Default" { print $2 }' "$1/profiles.ini" |
        while IFS= read -r profile; do
          case $profile in
            /*) echo "$profile" ;;
            *) echo "$1/$profile" ;;
          esac
        done
    }

    default_profiles ${lib.escapeShellArg firefoxDir} | while IFS= read -r profile; do
      run mkdir -p "$profile/extensions"
      run install -m 644 ${theme} "$profile/extensions/${themeId}.xpi"
    done

    default_profiles ${lib.escapeShellArg zenDir} | while IFS= read -r profile; do
      run mkdir -p "$profile/extensions"
      run install -m 644 ${lib.ted.configPath "zen/user.js"} "$profile/user.js"
      run install -D -m 644 ${lib.ted.configPath "zen/userChrome.css"} "$profile/chrome/userChrome.css"
      # Zen downloads listed mods on its next update check (first launch on a
      # new profile)
      run install -m 644 ${lib.ted.configPath "zen/zen-mods-export.json"} "$profile/zen-themes.json"
      run install -m 644 ${theme} "$profile/extensions/${themeId}.xpi"
    done
  '';
}
