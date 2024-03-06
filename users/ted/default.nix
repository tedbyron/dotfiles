{ pkgs, lib, isDarwin, isWsl, ... }:
let
  name = baseNameOf (toString ./.);
  home = if isDarwin then "/Users/${name}" else "/home/${name}";
in
{
  users.users.${name} = {
    inherit home;
    description = "Teddy Byron";
    shell = pkgs.zsh;
  };

  home-manager.users.${name} = {
    programs = import ./programs.nix { inherit pkgs; };
    targets.genericLinux.enable = isWsl;

    home = {
      stateVersion = "23.11";
      homeDirectory = home;
      packages = import ./packages.nix { inherit pkgs; };
      username = name;

      file = {
        ".iex.exs".source = ../../.iex.exs;

        ".config/nvim" = {
          source = ../../.config/nvim;
          recursive = true;
        };

        ".gnupg/gpg-agent.conf" = {
          enable = isDarwin;
          onChange = "gpgconf --reload gpg-agent";

          text =
            if isDarwin
            then
              ''
                pinentry-program ${pkgs.pinentry_mac.binaryPath}
              ''
            else null;
        };
      };
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
