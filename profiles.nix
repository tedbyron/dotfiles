let
  defaultUser = {
    name = "ted";
    description = "Teddy Byron";
    email = "ted@tedbyron.com";
  };

  mkProfile =
    { system
    , user ? defaultUser
    , config ? { }
    }:
    {
      inherit system;

      modules = [{
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.${user.name} = {
            home.stateVersion = "22.11";
            home.username = user.name;
            imports = [ ./home.nix ];
          };
        };
      }] ++ [ config ];
    };
in
{
  teds-mac = mkProfile {
    system = "aarch64-darwin";
    config = {
      networking = rec {
        computerName = "Ted's Mac";
        hostName = "teds-mac";
        localHostName = hostName;
      };
    };
  };

  teds-work-mac = mkProfile {
    system = "x86_64-darwin";
    config = {
      networking = rec {
        computerName = "Ted's Work Mac";
        hostName = "teds-work-mac";
        localHostName = hostName;
      };
    };
  };
}
