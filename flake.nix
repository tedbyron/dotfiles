{
  description = "tedbyron's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    curlio = {
      url = "path:./flakes/curlio";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    dircolors = {
      url = "path:./flakes/dircolors";

      inputs = {
        nixpkgs.follows = "nixpkgs-unstable";
        flake-utils.follows = "flake-utils";
      };
    };

    spicetify-nix = {
      url = "github:gerg-l/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    let
      inherit (lib.ted) mkSystem;
      inherit (flake-utils.lib.system) aarch64-darwin;

      overlays = [ ];

      lib = nixpkgs.lib.extend (
        final: _: {
          ted = import ./lib {
            inherit self inputs;
            lib = final;
          };
        }
      );
    in
    {
      darwinConfigurations = {
        teds-laptop = mkSystem "teds-laptop" {
          inherit overlays;
          system = aarch64-darwin;
        };
        teds-work-laptop = mkSystem "teds-work-laptop" {
          inherit overlays;
          system = aarch64-darwin;
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (system: {
      packages = inputs.curlio.outputs.packages.${system} // {
        dircolors = inputs.dircolors.outputs.packages.${system}.default;
      };
    });
}
