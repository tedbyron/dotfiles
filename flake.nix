{
  description = "tedbyron's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    let
      inherit (lib.my) mapHosts;
      inherit (flake-utils.lib) system;

      overlays = [ inputs.neovim-nightly-overlay.overlay ];

      lib = nixpkgs.lib.extend (self: super: {
        my = import ./lib {
          inherit inputs nixpkgs overlays;
          lib = self;
        };
      });
    in
    {
      darwinConfigurations = (mapHosts system.aarch64-darwin ./hosts/aarch64-darwin);
    };
}
