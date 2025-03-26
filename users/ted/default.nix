{
  self,
  config,
  inputs,
  pkgs,
  unstable,
  lib,
  system,
  isDarwin,
  isWsl,
  ...
}:
let
  name = baseNameOf (toString ./.);
  home = if isDarwin then "/Users/${name}" else "/home/${name}";
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

  system.defaults.screencapture = lib.optionalAttrs isDarwin {
    location = "${home}/Pictures/Screenshots";
  };

  home-manager.users.${name} = {
    imports = [ inputs.spicetify-nix.homeManagerModules.default ];

    targets.genericLinux.enable = isWsl;

    home = {
      stateVersion = "23.11";
      homeDirectory = home;
      packages = import ./packages.nix {
        inherit
          pkgs
          unstable
          lib
          isDarwin
          ;
      };
      username = name;

      file =
        let
          # Dir read is impure.
          ffReleaseProfile = lib.findFirst (name: lib.hasSuffix ".default-release" name) null (
            builtins.attrNames (builtins.readDir "${home}/Library/Caches/Firefox/Profiles")
          );
        in
        {
          ".config/iex/.iex.exs".source = ../../.config/iex/.iex.exs;
          ".config/nvim/init.lua".source = ../../.config/nvim/init.lua;
          ".config/rustfmt.toml".source = ../../.config/rustfmt.toml;

          ".config/nvim/lua" = {
            source = ../../.config/nvim/lua;
            recursive = true;
          };

          ".hushlogin" = {
            enable = isDarwin;
            text = "";
          };

          "${config.home-manager.users.${name}.programs.gpg.homedir}/gpg-agent.conf" = {
            enable = isDarwin;
            onChange = "${lib.getBin pkgs.gnupg}/bin/gpgconf --kill gpg-agent";

            text = ''
              pinentry-program ${pkgs.pinentry_mac}/${pkgs.pinentry_mac.binaryPath}
              default-cache-ttl 34560000
              max-cache-ttl 34560000
            '';
          };
        }
        // lib.optionalAttrs (isDarwin && ffReleaseProfile != null) {
          "Library/Caches/Firefox/Profiles/${ffReleaseProfile}/chrome".source = ../../.config/firefox/chrome;
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
        isDarwin
        ;

      user = name;
    };

    targets.darwin = lib.optionalAttrs isDarwin {
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
