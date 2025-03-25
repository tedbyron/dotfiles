{ unstable, lib, ... }:
{
  nix = {
    channel.enable = false;
    configureBuildUsers = true;
    optimise.automatic = true;
    package = unstable.nixVersions.nix_2_24;
    useDaemon = true;

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    settings = {
      trusted-users = [ "@admin" ];

      experimental-features = lib.concatStringsSep " " [
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
