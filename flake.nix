{
  description = "tedbyron's nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-darwin.url = "nixpkgs/nixpkgs-24.11-darwin";
    nixpkgs-unstable.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";

    home-manager = {
      url = "home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-darwin = {
      url = "home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    darwin = {
      url = "nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    curlio = {
      url = "path:./flakes/curlio";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    curlio-darwin = {
      url = "path:./flakes/curlio";
      inputs = {
        nixpkgs.follows = "nixpkgs-darwin";
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
    treefmt-nix = {
      url = "github:/numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    apple-emoji-linux = {
      url = "github:samuelngs/apple-emoji-linux";
      inputs.nixpkgs.follows = "nixpkgs";
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
      nixpkgs-darwin,
      flake-utils,
      ...
    }:
    let
      overlays = [ ];

      isDarwin =
        system:
        builtins.elem system (
          with flake-utils.lib.system;
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
          lib = (if darwin then nixpkgs-darwin else nixpkgs).lib.extend (
            final: _: {
              ted = import ./lib {
                inherit self;
                lib = final;

                # https://nixos.org/manual/nixpkgs/unstable/#sec-config-options-reference
                pkgs = import (if darwin then nixpkgs-darwin else nixpkgs) {
                  inherit system overlays;
                  config.allowUnfree = true;
                };

                unstable = import self.inputs.nixpkgs-unstable {
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
    with flake-utils.lib.system;
    {
      darwinConfigurations = {
        teds-laptop = mkSystem {
          system = aarch64-darwin;
          host = "teds-laptop";
        };
        teds-work-laptop = mkSystem {
          system = aarch64-darwin;
          host = "teds-work-laptop";
        };
      };

      nixosConfigurations = {
        teds-desktop = mkSystem {
          system = x86_64-linux;
          host = "teds-desktop";
        };
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        darwin = isDarwin system;
        pkgs = (if darwin then nixpkgs-darwin else nixpkgs).legacyPackages.${system};
        curlio = if darwin then self.inputs.curlio-darwin else self.inputs.curlio;
        treefmt = (self.inputs.treefmt-nix.lib.evalModule pkgs ./treefmt.nix).config.build;
      in
      {
        checks.formatting = treefmt.check self;
        formatter = treefmt.wrapper;

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            just
            stylua
          ];
        };

        packages = (builtins.removeAttrs curlio.outputs.packages.${system} [ "default" ]) // {
          dircolors = self.inputs.dircolors.outputs.packages.${system}.default;
        };
      }
    );
}
