{
  self,
  config,
  pkgs,
  unstable,
  lib,
  darwin,
  wsl,
  ...
}:
let
  home = if darwin then "/Users/ted" else "/home/ted";
in
{
  users =
    {
      users.ted =
        {
          inherit home;
          description = "Teddy Byron";
          shell = pkgs.zsh;
          uid = if darwin then 501 else 1000;
        }
        // lib.optionalAttrs (!darwin) {
          isNormalUser = true;

          extraGroups = [
            "networkmanager"
            "wheel"
          ];
        };
    }
    // lib.optionalAttrs darwin {
      knownUsers = [ "ted" ];
    };

  home-manager.users.ted = {
    imports = [
      self.inputs.spicetify-nix.homeManagerModules.default
      ./modules
      ./programs
      ./packages.nix
    ];

    home = {
      stateVersion = "23.11";
      homeDirectory = home;
      username = "ted";

      file = {
        # ".config/iex/.iex.exs".source = lib.ted.configPath "iex/.iex.exs";
        ".config/just/justfile".source = ../../justfile;
        ".config/nvim/init.lua".source = lib.ted.configPath "nvim/init.lua";
        ".config/rustfmt.toml".source = lib.ted.configPath "rustfmt.toml";
        ".config/stylua.toml".source = lib.ted.configPath "stylua.toml";
        # ".config/tio/config".source = lib.ted.configPath "tio/config";

        ".config/nvim/lua" = {
          source = lib.ted.configPath "nvim/lua";
          recursive = true;
        };

        ".config/pam-gnupg" = {
          enable = !darwin;
          source = lib.ted.configPath "pam-gnupg";
        };

        ".hushlogin" = {
          enable = darwin;
          text = "";
        };

        "${config.home-manager.users.ted.programs.gpg.homedir}/gpg-agent.conf" = {
          enable = true;
          onChange = "${lib.getBin pkgs.gnupg}/bin/gpgconf --kill gpg-agent";

          text =
            ''
              allow-preset-passphrase
              default-cache-ttl 34560000
              max-cache-ttl 34560000
            ''
            + lib.optionalString darwin ''
              pinentry-program ${pkgs.pinentry_mac}/${pkgs.pinentry_mac.binaryPath}
            '';
        };

        firefoxChrome =
          let
            profilesDir = "${home}/Library/Caches/Firefox/Profiles";
            # Dir read is impure.
            releaseProfile = lib.optionalString (builtins.pathExists profilesDir) (
              lib.findFirst (name: lib.hasSuffix ".default-release" name) "" (
                builtins.attrNames (builtins.readDir profilesDir)
              )
            );
          in
          {
            enable = darwin && releaseProfile != "";
            source = ../../.config/firefox/chrome;
            target = "Library/Caches/Firefox/Profiles/${releaseProfile}/chrome";
          };
      };

      # TODO: 25.05
      # pointerCursor = {
      #   enable = !darwin;
      #   hyprcursor.enable = true;
      # };
    };

    services =
      { }
      // lib.optionalAttrs (!darwin) {
        gnome-keyring.enable = true;
        hypridle.enable = false; # TODO
        hyprpaper.enable = false; # TODO
        # hyprpolkitagent.enable = true; # TODO 25.05

        dunst = {
          enable = true;
          # TODO: icon theme
          waylandDisplay = "wayland-1";
        };
      };

    targets = {
      genericLinux.enable = wsl;

      darwin = lib.optionalAttrs darwin {
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
  };
}
// lib.optionalAttrs darwin {
  system.defaults.screencapture = lib.optionalAttrs darwin {
    location = "${home}/Pictures/screenshots";
  };
}
