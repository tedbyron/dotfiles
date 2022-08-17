{ nixpkgs }:
let
  defaultUser = {
    description = "Teddy Byron";
    email = "ted@tedbyron.com";
    name = "ted";
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
            home.userInfo = user.name;
          };
        };
        users.users.${user.name} = {
          inherit (user) description name;

          home = (
            if builtins.elem system nixpkgs.lib.platforms.darwin
            then "/Users/"
            else "/home/"
          ) + user.name;
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
