{
  self,
  pkgs,
  unstable,
  lib,
}:
{
  mkSystem =
    {
      darwin,
      wsl,
      host,
      overlays,
    }:
    let
      inherit (self) inputs;
      homeManager = if darwin then inputs.home-manager-darwin else inputs.home-manager;
      osHmModules = if darwin then homeManager.darwinModules else homeManager.nixosModules;
      system = if darwin then inputs.darwin.lib.darwinSystem else lib.nixosSystem;
      stylixModules = if darwin then inputs.stylix.darwinModules else inputs.stylix.nixosModules;

      args = {
        lib = lib.extend (_: _: homeManager.lib);

        inherit
          self
          unstable
          darwin
          wsl
          ;
      };
    in
    system {
      specialArgs = args;

      modules = [
        osHmModules.home-manager
        stylixModules.stylix
        (lib.optionalAttrs wsl inputs.nixos-wsl.nixosModules.wsl)
        ../modules
        (import ../hosts/${host})

        {
          nixpkgs = { inherit pkgs overlays; };

          home-manager = {
            backupFileExtension = "hm-backup";
            extraSpecialArgs = args;
            useGlobalPkgs = true;
            useUserPackages = true;
          };
        }
      ];
    };
}
