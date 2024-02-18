{ pkgs, ... }:
let
  homebrew = import ./homebrew.nix;
  system = import ./system.nix;
in
{
  inherit homebrew system;

  pkgs.config.allowUnfree = true;
  security.pam.enableSudoTouchIdAuth = true;

  environment = {
    loginShell = "${pkgs.zsh}/bin/zsh -l";
    pathsToLink = [ "/usr/share/zsh" ];
    shells = with pkgs; [ bashInteractive zsh ];
    systemPackages = [ ];
  };

  nix = {
    configureBuildUsers = true;
    gc.automatic = true;
    useDaemon = true;

    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      extra-platforms = [ ];
      max-jobs = "auto";
      trusted-users = [ "@admin" ];

      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://nixpkgs.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      ];
    };
  };
}
