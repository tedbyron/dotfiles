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
      darwin,
      host,
      overlays ? [ ],
      isWsl ? false,
    }:
    let
      inherit (homeManager) darwinModules nixosModules;
      inherit (inputs.darwin.lib) darwinSystem;
      inherit (inputs.nixos-wsl.nixosModules) wsl;

      homeManager = if darwin then inputs.home-manager-darwin else inputs.home-manager;
      osModules = if darwin then darwinModules else nixosModules;
      system' = if darwin then darwinSystem else lib.nixosSystem;
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
          isWsl
          overlays
          ;

        lib = lib.extend (_: _: homeManager.lib);
      };

      modules = [
        osModules.home-manager
        (lib.optionalAttrs isWsl wsl)
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
