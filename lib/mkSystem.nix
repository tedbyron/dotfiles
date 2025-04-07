{
  self,
  inputs,
  pkgs,
  unstable,
  lib,
}:
{
  mkSystem =
    {
      system,
      darwin ? false,
      wsl ? false,
      host,
      overlays ? [ ],
    }:
    let
      inherit (homeManager) darwinModules nixosModules;

      homeManager = if darwin then inputs.home-manager-darwin else inputs.home-manager;
      osModules = if darwin then darwinModules else nixosModules;
      system' = if darwin then inputs.darwin.lib.darwinSystem else lib.nixosSystem;
    in
    system' {
      inherit system;

      specialArgs = {
        inherit
          self
          inputs
          unstable
          system
          darwin
          wsl
          overlays
          ;

        lib = lib.extend (_: _: homeManager.lib);
      };

      modules = [
        osModules.home-manager
        (lib.optionalAttrs wsl inputs.nixos-wsl.nixosModules.wsl)
        ../modules
        (import ../hosts/${host})

        {
          nixpkgs.pkgs = pkgs;

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
    };
}
