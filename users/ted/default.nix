{
  pkgs,
  lib,
  darwin,
  wsl,
  ...
}:
let
  username = "ted";
  name = "Teddy Byron";
  home = if darwin then "/Users/${username}" else "/home/${username}";
in
{
  users = {
    users.ted = {
      inherit home;
      description = name;
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
    knownUsers = [ username ];
  };

  home-manager.users.ted = {
    imports = [
      ./modules
      ./programs
      ./file.nix
      ./packages.nix
    ];

    home = {
      inherit username;
      stateVersion = "23.11";
      homeDirectory = home;
      sessionPath = [ "$HOME/git/dotfiles/bin" ];
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
        copyApps.enable = true;
        currentHostDefaults."com.apple.controlcenter".BatteryShowPercentage = false;
        linkApps.enable = false;
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
  system.defaults.dock.persistent-others = [
    {
      folder = {
        path = "${home}/Downloads";
        showas = "fan";
        displayas = "stack";
        arrangement = "date-added";
      };
    }
  ];
}
