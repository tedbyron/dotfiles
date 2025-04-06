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
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
    dircolors-darwin = {
      url = "path:./flakes/dircolors";
      inputs = {
        nixpkgs.follows = "nixpkgs-darwin";
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
      nixpkgs-darwin,
      flake-utils,
      ...
    }@inputs:
    let
      inherit (flake-utils.lib.system) aarch64-darwin x86_64-darwin;

      overlays = [ ];

      isDarwin =
        system:
        builtins.elem system [
          aarch64-darwin
          x86_64-darwin
        ];
      mkSystem =
        system: name:
        let
          darwin = isDarwin system;
          lib = (if darwin then nixpkgs-darwin else nixpkgs).lib.extend (
            final: _: {
              ted = import ./lib {
                inherit self inputs;
                lib = final;
              };
            }
          );
        in
        lib.ted.mkSystem name { inherit system darwin overlays; };
    in
    {
      darwinConfigurations = {
        teds-laptop = mkSystem aarch64-darwin "teds-laptop";
        teds-work-laptop = mkSystem aarch64-darwin "teds-work-laptop";
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        darwin = isDarwin system;
        pkgs = if darwin then nixpkgs-darwin else nixpkgs;
        curlio = if darwin then inputs.curlio-darwin else inputs.curlio;
        dircolors = if darwin then inputs.dircolors-darwin else inputs.dircolors;
      in
      {
        formatter = pkgs.legacyPackages.${system}.nixfmt-rfc-style;

        packages = curlio.outputs.packages.${system} // {
          dircolors = dircolors.outputs.packages.${system}.default;
        };
      }
    );
}
