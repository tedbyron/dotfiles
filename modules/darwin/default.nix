{ self, pkgs, system, ... }:
{
  imports = [
    ./dock.nix
    ./system.nix
  ];

  security.pam.enableSudoTouchIdAuth = true;

  programs = {
    gnupg.agent.enable = true;
    zsh.enable = true;
  };

  environment = {
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
      gnused
      less
      ouch
      python3
    ];

    variables = {
      HOMEBREW_NO_ANALYTICS = "1";
      LANG = "en_US.UTF-8";
    };
  };

  homebrew = {
    enable = true;

    casks = [
      "firefox"
      "mullvadvpn"
      "rectangle"
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
    fonts = [ self.outputs.packages.${system}.curlio-ttf ];
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
      trusted-users = [ "@admin" ];

      experimental-features = builtins.concatStringsSep " " [
        "auto-allocate-uids"
        "flakes"
        "nix-command"
      ];

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
    };
  };
}
