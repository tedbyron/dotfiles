{ inputs, lib, ... }:
{
  mkSystem = host: { system
                   , overlays ? [ ]
                   , isWsl ? false
                   }:
    let
      inherit (lib) nixosSystem optionalAttrs;
      inherit (inputs.darwin.lib) darwinSystem;
      inherit (inputs.home-manager) darwinModules nixosModules;
      inherit (inputs.nixos-wsl.nixosModules) wsl;

      isDarwin = builtins.elem system [ "aarch64-darwin" "x86_64-darwin" ];
      osModules = if isDarwin then darwinModules else nixosModules;
      mkSystem = if isDarwin then darwinSystem else nixosSystem;
    in
    mkSystem {
      inherit system;
      specialArgs = { inherit host isDarwin isWsl; };

      modules = [
        (optionalAttrs isWsl wsl)
        osModules.home-manager
        # ../modules
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
