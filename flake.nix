{
  description = "tedbyron's nix config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, darwin, ... }@inputs:
    let
      inherit (inputs.flake-utils.lib) system;

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

      mkNetworkModule = { name }:
        let nameNoSpaces = nixpkgs.lib.stringAsChars (x: if x == " " then "-" else x) name;
        in
        {
          networking = {
            computerName = name;
            hostName = nameNoSpaces;
            localHostName = nameNoSpaces;
          };
        };
    in
    {
      darwinConfigurations = {
        teds-mac = mkDarwinSystem {
          system = system.aarch64-darwin;
          modules = [ mkNetworkModule "teds-mac" ];
        };

        teds-work-mac = mkDarwinSystem {
          system = system.x86_64-darwin;
          modules = [ mkNetworkModule "teds-work-mac" ];
        };
      };
    };
}
