{
  self,
  inputs,
  lib,
}:
{
  mkSystem =
    host:
    {
      system,
      darwin,
      overlays ? [ ],
      isWsl ? false,
    }:
    let
      inherit (inputs.darwin.lib) darwinSystem;
      inherit (inputs.home-manager) darwinModules nixosModules;
      inherit (inputs.nixos-wsl.nixosModules) wsl;

      osModules = if darwin then darwinModules else nixosModules;
      mkSystem = if darwin then darwinSystem else lib.nixosSystem;

      unstable = import inputs.nixpkgs-unstable {
        inherit system;

        config.allowUnfree = true;
        overlays = overlays;
      };
    in
    mkSystem {
      inherit system;

      specialArgs = {
        inherit
          self
          inputs
          unstable
          system
          darwin
          isWsl
          ;
      };

      modules = [
        osModules.home-manager
        (lib.optionalAttrs isWsl wsl)
        ../modules
        (import ../hosts/${host})

        {
          nixpkgs = {
            config.allowUnfree = true;
            hostPlatform = system;
            overlays = overlays;
          };

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
    };
}
