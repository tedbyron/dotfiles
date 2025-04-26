{
  self,
  pkgs,
  unstable,
  lib,
}:
{
  mkSystem =
    {
      darwin ? false,
      wsl ? false,
      host,
      overlays ? [ ],
    }:
    let
      inherit (homeManager) darwinModules nixosModules;

      homeManager = if darwin then self.inputs.home-manager-darwin else self.inputs.home-manager;
      osModules = if darwin then darwinModules else nixosModules;
      system = if darwin then self.inputs.darwin.lib.darwinSystem else lib.nixosSystem;

      args = {
        inherit
          self
          unstable
          darwin
          wsl
          overlays
          ;

        lib = lib.extend (_: _: homeManager.lib);
      };
    in
    system {
      specialArgs = args;

      modules = [
        osModules.home-manager
        (lib.optionalAttrs wsl self.inputs.nixos-wsl.nixosModules.wsl)
        ../modules
        (import ../hosts/${host})

        {
          nixpkgs.pkgs = pkgs;

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = args;
          };
        }
      ];
    };
}
