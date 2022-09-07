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

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, darwin, home-manager, ... }@inputs:
    let
      defaultUser = {
        description = "Teddy Byron";
        email = "ted@tedbyron.com";
        name = "ted";
        key = "E0496EDDDF6BB87D";
      };

      mkDarwinSystem =
        { system
        , user ? defaultUser
        , modules
        }:
        darwin.lib.darwinSystem {
          inherit inputs system;

          modules = [
            home-manager.darwinModules.home-manager
            ./modules/darwin.nix
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${user.name} = {
                  inherit user;
                  imports = [ ./modules/home ];
                };
              };

              users.users.${user.name} = {
                inherit (user) description name;

                home = "/Users/${user.name}";
              };
            }
          ] ++ modules;
        };
    in
    {
      darwinConfigurations = {
        teds-mac = mkDarwinSystem {
          system = "aarch64-darwin";
          modules = [{
            networking = rec {
              computerName = "teds-mac";
              hostName = computerName;
              localHostName = hostName;
            };
          }];
        };

        teds-work-mac = mkDarwinSystem {
          system = "x86_64-darwin";
          modules = [{
            networking = rec {
              computerName = "teds-mac";
              hostName = computerName;
              localHostName = hostName;
            };
          }];
        };
      };
    };
}
