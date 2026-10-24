{
  pkgs,
  darwin,
  lib,
  ...
}:
{
  nix =
    if darwin then
      { enable = false; }
    else
      {
        channel.enable = false;
        nixPath = [ "nixpkgs=${pkgs.path}" ];
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
            "https://tedbyron.cachix.org"
          ];

          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "tedbyron.cachix.org-1:sSeqTh3XNopwXPm6oYnr0dqwqEVxcl13apV0wjfNxcY="
          ];
        };
      };

  # No channels, so give <nixpkgs> lookups (nix-index, nix-shell -p) the
  # flake's nixpkgs. nix.nixPath needs nix.enable on darwin.
  environment.variables = lib.mkIf darwin { NIX_PATH = "nixpkgs=${pkgs.path}"; };

  environment.etc."nix/nix.conf".text = lib.mkIf darwin ''
    download-buffer-size = 536870912
    experimental-features = auto-allocate-uids flakes nix-command pipe-operators
    substituters = https://cache.nixos.org/ https://cachix.cachix.org https://nix-community.cachix.org https://tedbyron.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs= tedbyron.cachix.org-1:sSeqTh3XNopwXPm6oYnr0dqwqEVxcl13apV0wjfNxcY=
  '';
}
