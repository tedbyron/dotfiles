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

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-compat.url = "github:edolstra/flake-compat";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (lib.ted) mkSystem;

      lib = nixpkgs.lib.extend (final: prev: {
        ted = import ./lib {
          inherit self inputs nixpkgs;
          lib = final;
        };
      });
    in
    {
      darwinConfigurations = {
        gamma = mkSystem "gamma" {
          system = "aarch64-darwin";
        };

        delta = mkSystem "delta" {
          system = "x86_64-darwin";
        };
      };
    };
}
