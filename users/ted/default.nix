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

    programs = import ./programs.nix { inherit inputs pkgs unstable system isDarwin; };
    targets.genericLinux.enable = isWsl;

    home = {
      stateVersion = "23.11";
      homeDirectory = home;
      packages = import ./packages.nix { inherit pkgs lib isDarwin; };
      username = name;

      file = {
        ".config/rustfmt.toml".source = ../../.config/rustfmt.toml;
        ".hushlogin".enable = isDarwin;
        ".iex.exs".source = ../../.iex.exs;

        ".config/nvim/init.lua".source = ../../.config/nvim/init.lua;
        ".config/nvim/lua" = {
          source = ../../.config/nvim/lua;
          recursive = true;
        };

        "${config.home-manager.users.${name}.programs.gpg.homedir}/gpg-agent.conf" = {
          enable = isDarwin;
          onChange = "${lib.getBin pkgs.gnupg}/bin/gpgconf --reload gpg-agent";

          text =
            if isDarwin
            then ''
                pinentry-program ${pkgs.pinentry_mac}/${pkgs.pinentry_mac.binaryPath}
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
