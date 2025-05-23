{ pkgs, ... }:
{
  nix = {
    channel.enable = false;
    gc.automatic = true;
    optimise.automatic = true;
    package = pkgs.nixVersions.latest;

    settings = {
      download-buffer-size = 536870912; # 512MiB

      experimental-features = [
        "auto-allocate-uids"
        "flakes"
        "nix-command"
        "pipe-operators"
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
}
