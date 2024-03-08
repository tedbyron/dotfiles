{ config, pkgs, lib, isDarwin, ... }:
with lib;
let
  cfg = config.custom.dock;
  inherit (pkgs) dockutil;
in
{
  options = {
    custom.dock.enable = mkOption {
      description = "Enable dock";
      default = isDarwin;
      example = false;
    };

    custom.dock.entries = mkOption
      {
        description = "Dock applications";
        readOnly = true;

        type = with types; listOf (submodule {
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
  config =
    mkIf cfg.enable
      (
        let
          normalize = path: if hasSuffix ".app" path then path + "/" else path;
          entryURI = path: "file://" + (builtins.replaceStrings
            [" "   "!"   "\""  "#"   "$"   "%"   "&"   "'"   "("   ")"]
            ["%20" "%21" "%22" "%23" "%24" "%25" "%26" "%27" "%28" "%29"]
            (normalize path)
          );
          wantURIs = concatMapStrings
            (entry: "${entryURI entry.path}\n")
            cfg.entries;
          createEntries = concatMapStrings
            (entry: "${dockutil}/bin/dockutil --no-restart --add '${entry.path}' --section ${entry.section} ${entry.options}\n")
            cfg.entries;
        in
        {
          system.activationScripts.postUserActivation.text = ''
            haveURIs="$(${dockutil}/bin/dockutil --list | ${pkgs.coreutils}/bin/cut -f2)"
            if ! diff -wu <(echo -n "$haveURIs") <(echo -n '${wantURIs}') >&2 ; then
              ${dockutil}/bin/dockutil --no-restart --remove all
              ${createEntries}
              killall Dock
            fi
          '';
        }
      );
}
