{
  description = "tedbyron's nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-darwin.url = "nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";

    home-manager = {
      url = "home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-darwin = {
      url = "home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    darwin = {
      url = "nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos-26.05, pinned so flake updates don't rebuild Iosevka; bump the rev
    # by hand.
    nixpkgs-curlio.url = "github:NixOS/nixpkgs/da6dc0e7b26060f2f71ce3ef7088fb56ee44fa36";
    curlio = {
      url = "path:./flakes/curlio";
      inputs.nixpkgs.follows = "nixpkgs-curlio";
      inputs.flake-utils.follows = "flake-utils";
    };

    apple-emoji-linux = {
      url = "github:samuelngs/apple-emoji-linux";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:/numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    jelly-metrics = {
      url = "github:digital-shane/jelly-metrics";
      flake = false;
    };
    macos-process-exporter = {
      url = "github:digital-shane/macos-process-exporter";
      flake = false;
    };
    speedrr = {
      url = "github:itschasa/speedrr";
      flake = false;
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
      darwinConfigurations = builtins.listToAttrs (
        map
          (host: {
            name = host;
            value = mkSystem {
              inherit host;
              system = aarch64-darwin;
            };
          })
          [
            "teds-laptop"
            "teds-mac-mini"
            "teds-work-laptop"
          ]
      );

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
        treefmt = (inputs.treefmt-nix.lib.evalModule pkgs ./format.nix).config.build;
      in
      {
        checks.formatting = treefmt.check self;
        formatter = treefmt.wrapper;
        packages = removeAttrs inputs.curlio.outputs.packages.${system} [ "default" ];

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            just
            stylua
          ];
        };
      }
    );
}
