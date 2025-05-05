{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "flake-utils";
  };

  outputs =
    { self, ... }@inputs:
    inputs.utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
      in
      with pkgs;
      {
        formatter = nixfmt-rfc-style;
        devShells.default = mkShellNoCC {
          packages = [ ];
        };
      }
    );
}
