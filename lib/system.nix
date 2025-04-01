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

      # https://nixos.org/manual/nixpkgs/unstable/#sec-config-options-reference
      pkgs = import (if darwin then inputs.nixpkgs-darwin else inputs.nixpkgs) {
        inherit system overlays;
        config.allowUnfree = true;
      };
      unstable = import inputs.nixpkgs-unstable {
        inherit system overlays;
        config.allowUnfree = true;
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
          overlays
          ;
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
