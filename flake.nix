{
  description = "Ted's Nix config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
    flake-utils.url = "github:numtide/flake-utils";

    comma.url = "github:nix-community/comma";
    comma.inputs.nixpkgs.follows = "nixpkgs";
    spacebar.url = "github:cmacrae/spacebar";
    spacebar.inputs.nixpkgs.follows = "nixpkgs";
    neovim-overlay.url = "github:nix-community/neovim-nightly-overlay";
    neovim-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, darwin, home-manager, flake-utils, ... }@inputs:
    let
      inherit (darwin.lib) darwinSystem;
      inherit (nixpkgs.lib) attrValues;

      nixpkgsConfig.config = { allowUnfree = true; };
    in
    {
      darwinConfigurations = {
        teds-mac = darwinSystem {
          system = "aarch64-darwin";
          modules = attrValues self.darwinModules ++ [
            ./darwin/aarch64/configuration.nix
            home-manager.darwinModules.home-manager
            {
              inherit nixpkgs;
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPkgs = true;
              home-manager.users.ted = import ./home.nix;
            }
          ];
        };
      };
    };
}
