{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
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
