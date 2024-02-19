{ pkgs, lib, ... }:
{
  imports = [ ./system.nix ];

  security.pam.enableSudoTouchIdAuth = true;

  programs = {
    gnupg.agent.enable = true;
    nix-index.enable = true;
    zsh.enable = true;
  };

  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";

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
      gnugrep
      gnutar
      gnused
    ];

    # TODO: vlc
  };

  homebrew = {
    enable = true;

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

  # fonts = with pkgs; [
  #   (iosevka.override { })
  # ];

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
