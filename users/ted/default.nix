{
  self,
  pkgs,
  lib,
  darwin,
  wsl,
  ...
}:
let
  home = if darwin then "/Users/ted" else "/home/ted";
in
{
  users = {
    users.ted = {
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
      ./file.nix
      ./packages.nix
    ];

    home = {
      stateVersion = "23.11";
      homeDirectory = home;
      sessionPath = [ "$HOME/git/dotfiles/bin" ];
      username = "ted";
    }
    // lib.optionalAttrs (!darwin) {
      pointerCursor = {
        enable = !darwin;
        hyprcursor.enable = true;
        gtk.enable = true;
        name = "phinger-cursors-dark";
        size = 12;
      };
    };

    services = lib.optionalAttrs (!darwin) {
      gnome-keyring.enable = true;
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
