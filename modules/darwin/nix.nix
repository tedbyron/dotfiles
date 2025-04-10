{
  inputs,
  pkgs,
  system,
  overlays,
  ...
}:
{
  nix = {
    channel.enable = false;
    configureBuildUsers = true;
    package = pkgs.nixVersions.latest;
    useDaemon = true;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";

      interval = [
        {
          Hour = 3;
          Minute = 30;
        }
      ];
    };

    optimise = {
      automatic = true;

      interval = [
        {
          Hour = 4;
          Minute = 30;
        }
      ];
    };

    settings = {
      trusted-users = [ "@admin" ];

      experimental-features = builtins.concatStringsSep " " [
        "auto-allocate-uids"
        "flakes"
        "nix-command"
      ];

      substituters = [
        "https://cache.nixos.org/"
        "https://cachix.cachix.org"
        "https://nix-community.cachix.org"
      ];

      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  nixpkgs = {
    inherit system overlays;
    config.allowUnfree = true;
    source = inputs.nixpkgs-darwin;
  };
}
