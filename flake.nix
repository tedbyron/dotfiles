{
  description = "Ted's Nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    flake-compat.url = "github:edolstra/flake-compat";
    flake-compat.flake = false;
    flake-utils.url = "github:numtide/flake-utils";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.inputs.utils.follows = "flake-utils";

    # comma = {
    #   url = "github:nix-community/comma";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # neovim-overlay = {
    #   url = "github:nix-community/neovim-nightly-overlay";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # spacebar = {
    #   url = "github:cmacrae/spacebar";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { nixpkgs, darwin, home-manager, ... }:
    let
      inherit (darwin.lib) darwinSystem;

      userInfo = rec {
        name = "ted";
        description = "Teddy Byron";
        email = "ted@tedbyron.com";
        # home = "${homePrefix}/${name}";
        # nixConfigDirectory = "${homePrefix}/${name}/.config/nixpkgs";
      };

      mkDarwinSystem = { system, extraModules }:
        darwinSystem {
          inherit system;
          modules = [
            home-manager.darwinModules.home-manager
            homeManagerModule
            ./modules/darwin.nix
            { users.users.${userInfo.username} = userInfo; }
          ] ++ extraModules;
        };
    in
    {
      darwinConfigurations = {
        teds-mac = mkDarwinSystem {
          system = "aarch64-darwin";
          extraModules = [
            {
              networking.computerName = "Ted's Mac";
              networking.hostName = "teds-mac";
            }
          ];
        };

        teds-work-mac = mkDarwinSystem {
          system = "x86_64-darwin";
          extraModules = [
            {
              networking.computerName = "Ted's Work Mac";
              networking.hostName = "teds-work-mac";
            }
          ];
        };
      };
    };
}
