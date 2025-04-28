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
      inherit (self) inputs;
      homeManager = if darwin then inputs.home-manager-darwin else inputs.home-manager;
      osModules = if darwin then homeManager.darwinModules else homeManager.nixosModules;
      system = if darwin then inputs.darwin.lib.darwinSystem else lib.nixosSystem;
      stylixModules = if darwin then inputs.stylix.darwinModules else inputs.stylix.nixosModules;

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
        stylixModules.stylix
        (lib.optionalAttrs wsl inputs.nixos-wsl.nixosModules.wsl)
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
