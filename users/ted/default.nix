{ pkgs, lib, isDarwin, ... }:
let
  name = "ted";
  home = if isDarwin then "/Users/${name}" else "/home/${name}";
in
{
  imports = (lib.optional isDarwin ./darwin.nix);

  users.users.${name} = {
    inherit home;
    description = "Teddy Byron";
    shell = pkgs.zsh;
  };

  home-manager.users.${name} = {
    home = {
      stateVersion = "23.11";
      homeDirectory = home;
    };

    targets.darwin = {
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
