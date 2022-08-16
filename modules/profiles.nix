{ nixpkgs }:
let
  inherit (builtins) elem;
  inherit (nixpkgs.lib) platforms;

  defaultUser = {
    name = "ted";
    description = "Teddy Byron";
    email = "ted@tedbyron.com";
  };

  mkProfile =
    { system
    , user ? defaultUser
    , modules ? [ ]
    }:
    {
      inherit system;

      modules = modules ++ [{
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user.name} = {
            imports = [ ./home.nix ];
            home.username = user.name;
          };
        };
        users.users.${user.name} = {
          description = user.description;
          home = "${if elem system platforms.darwin then "/Users" else "/home"}/${user.name}";
          name = user.name;
        };
      }];
    };
in
{
  teds-mac = mkProfile {
    system = "aarch64-darwin";
    modules = [{
      networking = rec {
        computerName = "Ted's Mac";
        hostName = "teds-mac";
        localHostName = hostName;
      };
    }];
  };

  teds-work-mac = mkProfile {
    system = "x86_64-darwin";
    modules = [{
      networking = rec {
        computerName = "Ted's Work Mac";
        hostName = "teds-work-mac";
        localHostName = hostName;
      };
    }];
  };
}
