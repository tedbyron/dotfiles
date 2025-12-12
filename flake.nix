{
  description = "tedbyron's nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-darwin.url = "nixpkgs/nixpkgs-25.11-darwin";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";

    home-manager = {
      url = "home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-darwin = {
      url = "home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    darwin = {
      url = "nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    curlio = {
      url = "path:./flakes/curlio";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    curlio-darwin = {
      url = "path:./flakes/curlio";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
      inputs.flake-utils.follows = "flake-utils";
    };

    apple-emoji-linux = {
      url = "github:samuelngs/apple-emoji-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:/numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      overlays = [ ];

      isDarwin =
        system:
        builtins.elem system (
          with inputs.flake-utils.lib.system;
          [
            aarch64-darwin
            x86_64-darwin
          ]
        );

      mkSystem =
        {
          system,
          host,
          wsl ? false,
        }:
        let
          darwin = isDarwin system;

          lib = (if darwin then inputs.nixpkgs-darwin else inputs.nixpkgs).lib.extend (
            final: _: {
              ted = import ./lib {
                inherit self;
                lib = final;

                pkgs = import (if darwin then inputs.nixpkgs-darwin else inputs.nixpkgs) {
                  inherit system overlays;
                  config.allowUnfree = true;
                };

                unstable = import inputs.nixpkgs-unstable {
                  inherit system overlays;
                  config.allowUnfree = true;
                };
              };
            }
          );
        in
        lib.ted.mkSystem {
          inherit
            darwin
            wsl
            host
            overlays
            ;
        };
    in
    with inputs.flake-utils.lib.system;
    {
      darwinConfigurations = {
        teds-laptop = mkSystem {
          host = "teds-laptop";
          system = aarch64-darwin;
        };
        teds-work-laptop = mkSystem {
          host = "teds-work-laptop";
          system = aarch64-darwin;
        };
      };

      nixosConfigurations = {
        teds-desktop = mkSystem {
          host = "teds-desktop";
          system = x86_64-linux;
        };
      };

      templates =
        let
          templates = builtins.mapAttrs (n: _: {
            path = ./templates/${n};
            description = n;
          }) (builtins.readDir ./templates);
        in
        templates
        // {
          default = builtins.getAttr "trivial" templates;
        };
    }
    // inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        darwin = isDarwin system;
        nixpkgs = if darwin then inputs.nixpkgs-darwin else inputs.nixpkgs;
        pkgs = import nixpkgs { inherit system overlays; };
        curlio = if darwin then inputs.curlio-darwin else inputs.curlio;
        treefmt = (inputs.treefmt-nix.lib.evalModule pkgs ./format.nix).config.build;
      in
      {
        checks.formatting = treefmt.check self;
        formatter = treefmt.wrapper;
        packages = builtins.removeAttrs curlio.outputs.packages.${system} [ "default" ];

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            just
            stylua
          ];
        };
      }
    );
}
