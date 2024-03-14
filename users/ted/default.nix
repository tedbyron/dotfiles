{ inputs, config, pkgs, unstable, lib, system, isDarwin, isWsl, ... }:
let
  name = baseNameOf (toString ./.);
  home =
    if isDarwin
    then "/Users/${name}"
    else "/home/${name}";
in
{
  users.users.${name} = {
    inherit home;
    description = "Teddy Byron";
    shell = pkgs.zsh;
  };

  home-manager.users.${name} = {
    imports = [ inputs.spicetify-nix.homeManagerModule ];

    programs = import ./programs { inherit inputs pkgs unstable lib system isDarwin; };
    targets.genericLinux.enable = isWsl;

    home = {
      stateVersion = "23.11";
      homeDirectory = home;
      packages = import ./packages.nix { inherit pkgs unstable lib isDarwin; };
      username = name;

      file = {
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
          '';
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
