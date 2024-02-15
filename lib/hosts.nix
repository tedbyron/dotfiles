{ inputs, nixpkgs, lib, ... }:
let
  inherit (lib.my) mapModules mkHost;
  inherit (inputs.flake-utils.lib) system;

  darwinSystems = [ system.aarch64-darwin system.x86_64-darwin ];

  # homeMgr = if isDarwin
  #   then inputs.darwin.lib.darwinModules
  #   else inputs.home-manager.nixosModules;
in
{
  mkHost = path: { system, ... }@attrs:
    if darwinSystems ? system
    then inputs.darwin.lib.darwinSystem
    else lib.nixosSystem {
      inherit system;

      specialArgs = { inherit lib inputs system; };

      modules = [
        {
          nixpkgs.pkgs = pkgs;
          networking.hostName = removeSuffix ".nix" (baseNameOf path);
        }
        (filterAttrs (n: v: !elem n [ "system" ]) attrs)
        ../.
        (import path)
      ];
    };

  mapHosts = dir: { system, ... }@attrs:
    mapModules dir (hostPath: mkHost system hostPath attrs);
}
