{
  self,
  config,
  inputs,
  pkgs,
  unstable,
  lib,
  system,
  darwin,
  wsl,
  ...
}:
let
  name = baseNameOf (toString ./.);
  home = if darwin then "/Users/${name}" else "/home/${name}";
in
{
  users = {
    knownUsers = [ name ];

    users.${name} = {
      inherit home;
      description = "Teddy Byron";
      shell = pkgs.zsh;
      uid = 501;
    };
  };

  system.defaults.screencapture = lib.optionalAttrs darwin {
    location = "${home}/Pictures/screenshots";
  };

  home-manager.users.${name} = {
    imports = [ inputs.spicetify-nix.homeManagerModules.default ];

    targets.genericLinux.enable = wsl;

    home = {
      stateVersion = "23.11";
      homeDirectory = home;
      packages = import ./packages.nix {
        inherit
          pkgs
          unstable
          lib
          darwin
          ;
      };
      username = name;

      file = {
        ".config/iex/.iex.exs".source = ../../.config/iex/.iex.exs;
        ".config/nvim/init.lua".source = ../../.config/nvim/init.lua;
        ".config/rustfmt.toml".source = ../../.config/rustfmt.toml;
        ".config/tio/config".source = ../../.config/tio/config;

        ".config/nvim/lua" = {
          source = ../../.config/nvim/lua;
          recursive = true;
        };

        ".hushlogin" = {
          enable = darwin;
          text = "";
        };

        "${config.home-manager.users.${name}.programs.gpg.homedir}/gpg-agent.conf" = {
          enable = darwin;
          onChange = "${lib.getBin pkgs.gnupg}/bin/gpgconf --kill gpg-agent";

          text = ''
            pinentry-program ${pkgs.pinentry_mac}/${pkgs.pinentry_mac.binaryPath}
            default-cache-ttl 34560000
            max-cache-ttl 34560000
          '';
        };

        firefoxChrome =
          let
            dir = "${home}/Library/Caches/Firefox/Profiles";
            # Dir read is impure.
            ffReleaseProfile = lib.optionalString (builtins.pathExists dir) (
              lib.findFirst (name: lib.hasSuffix ".default-release" name) "" (
                builtins.attrNames (builtins.readDir dir)
              )
            );
          in
          {
            enable = darwin && ffReleaseProfile != null;
            source = ../../.config/firefox/chrome;
            target = "Library/Caches/Firefox/Profiles/${ffReleaseProfile}/chrome";
          };
      };
    };

    programs = import ./programs {
      inherit
        self
        config
        inputs
        pkgs
        unstable
        lib
        system
        darwin
        ;

      user = name;
    };

    targets.darwin = lib.optionalAttrs darwin {
      currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = false;
      search = "DuckDuckGo";

      defaults = {
        "com.apple.dock".size-immutable = true;

        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };

        "com.apple.Safari" = {
          AutoFillCreditCardData = false;
          AutoFillPasswords = false;
          IncludeDevelopMenu = true;
        };
      };
    };
  };
}
