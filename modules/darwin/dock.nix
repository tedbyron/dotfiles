{ config, pkgs, lib, ... }:
let cfg = config.custom.dock;
in {
  options = {
    custom.dock.enable = lib.mkOption {
      description = "Enable dock";
      default = false;
      example = false;
    };

    custom.dock.entries = lib.mkOption {
      description = "Dock applications";
      readOnly = true;

      type = with lib.types;
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

  config = lib.mkIf cfg.enable (let
    normalize = path: if lib.hasSuffix ".app" path then path + "/" else path;
    entryURI = path:
      "file://" + (lib.concatMapStringsSep "/" (path:
        builtins.replaceStrings [ "%28" "%29" ] [ "(" ")" ]
        (lib.escapeURL path)) (lib.splitString "/" (normalize path)));
    wantURIs = lib.concatMapStrings (entry: ''
      ${entryURI entry.path}
    '') cfg.entries;
    createEntries = lib.concatMapStrings (entry: ''
      ${pkgs.dockutil}/bin/dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}
    '') cfg.entries;
  in {
    system.activationScripts.postUserActivation.text = ''
      haveURIs="$(${pkgs.dockutil}/bin/dockutil --list | ${pkgs.coreutils}/bin/cut -f2)"
      if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
        echo "Updating dock..." >&2
        ${pkgs.dockutil}/bin/dockutil --no-restart --remove all
        ${createEntries}
        killall Dock
      fi
    '';
  });
}
