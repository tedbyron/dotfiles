{ pkgs, lib, ... }:
{
  imports = [
    ./homebrew.nix
    ./system.nix
  ];

  security.pam.enableSudoTouchIdAuth = true;

  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    shells = with pkgs; [ bashInteractive zsh ];
  };

  nix = {
    configureBuildUsers = true;
    gc.automatic = true;
    useDaemon = true;

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
