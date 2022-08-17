{
  description = "Ted's Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, darwin, home-manager, ... }@inputs:
    let
      mkDarwinSystem = profile:
        darwin.lib.darwinSystem {
          inherit inputs;
          inherit (profile) system;

          modules = [
            home-manager.darwinModules.home-manager
            ./modules/darwin.nix
          ] ++ profile.modules;
        };

      profiles = import ./modules/profiles.nix { inherit nixpkgs; };
    in
    {
      darwinConfigurations = {
        teds-mac = mkDarwinSystem profiles.teds-mac;
        teds-work-mac = mkDarwinSystem profiles.teds-work-mac;
      };
    };
}
