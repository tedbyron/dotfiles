{ inputs, pkgs, lib, system, ... }:
{
  imports = [ ./dock.nix ./system.nix ];

  security.pam.enableSudoTouchIdAuth = true;

  programs = {
    gnupg.agent.enable = true;
    nix-index.enable = true;
    zsh.enable = true;
  };

  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    variables.HOMEBREW_NO_ANALYTICS = "1";

    shells = with pkgs; [
      bashInteractive
      zsh
    ];

    systemPackages = with pkgs; [
      binutils
      coreutils
      curl
      diffutils
      findutils
      gawkInteractive
      git
      gnugrep
      gnutar
      gnused
      python3
    ];
  };

  homebrew = {
    enable = true;

    casks = [
      "firefox"
      "mullvadvpn"
      "vlc"
    ];

    masApps = {
      NextDns = 1464122853;
      Bitwarden = 1352778147;
    };

    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
  };

  fonts = {
    fontDir.enable = true;
    fonts = [ inputs.curlio.outputs.packages.${system}.curlio-ttf ];
  };

  nix = {
    configureBuildUsers = true;
    useDaemon = true;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    settings = {
      auto-optimise-store = true;

      experimental-features = lib.concatStrings (lib.intersperse " "
        [
          "auto-allocate-uids"
          # "configurable-impure-env"
          "flakes"
          "nix-command"
        ]);

      substituters = [
        "https://cache.nixos.org/"
        "https://nixpkgs.cachix.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];

      trusted-users = [
        "root"
        "@admin"
      ];
    };
  };
}
