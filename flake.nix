{
  description = "tedbyron's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

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

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    curlio = {
      url = "github:tedbyron/curlio";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    spicetify-nix = {
      url = "github:tedbyron/spicetify-nix";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      inherit (lib.ted) mkSystem nixFilesIn;

      overlays = builtins.attrValues (nixFilesIn ./overlays);
      lib = nixpkgs.lib.extend (final: prev: {
        ted = import ./lib {
          inherit self inputs;
          lib = final;
        };
      });
    in
    {
      darwinConfigurations = {
        gamma = mkSystem "gamma" {
          inherit overlays;
          system = "aarch64-darwin";
        };

        delta = mkSystem "delta" {
          inherit overlays;
          system = "aarch64-darwin";
        };
      };
    };
}
