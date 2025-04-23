{
  config,
  pkgs,
  lib,
  darwin,
  ...
}:
let
  cfg = config.custom.dock;
  dockutilExe = lib.getExe pkgs.dockutil;
in
{
  options = {
    custom.dock.enable = lib.mkEnableOption "dock";

    custom.dock.entries = lib.mkOption {
      description = "Dock applications";
      readOnly = true;

      type =
        with lib.types;
        listOf (submodule {
          options = {
            path = lib.mkOption { type = str; };

            section = lib.mkOption {
              type = str;
              default = "apps";
            };

            options = lib.mkOption {
              type = str;
              default = "";
            };
          };
        });
    };
  };

  config = lib.mkIf (darwin && cfg.enable) (
    let
      normalize = path: if lib.hasSuffix ".app" path then path + "/" else path;
      entryURI =
        path:
        "file://"
        + (lib.concatMapStringsSep "/" (
          path:
          builtins.replaceStrings
            [
              "%28"
              "%29"
            ]
            [
              "("
              ")"
            ]
            (lib.escapeURL path)
        ) (lib.splitString "/" (normalize path)));
      wantURIs = lib.concatMapStrings (entry: ''
        ${entryURI entry.path}
      '') cfg.entries;
      createEntries = lib.concatMapStrings (entry: ''
        ${dockutilExe} \
          --no-restart \
          --add '${entry.path}' \
          --section ${entry.section} \
          ${entry.options}
      '') cfg.entries;
    in
    {
      system.activationScripts.postUserActivation.text = ''
        haveURIs="$(${dockutilExe} --list | ${lib.getExe' pkgs.coreutils "cut"} -f2)"
        if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
          echo "Updating dock..." >&2
          ${dockutilExe} --no-restart --remove all
          ${createEntries}
          killall Dock
        fi
      '';
    }
  );
}
