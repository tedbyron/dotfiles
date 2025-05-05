{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";
    treefmt.url = "github:/numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        treefmt =
          (inputs.treefmt.lib.evalModule pkgs {
            programs = {
              deadnix.enable = true;
              nixfmt.enable = true;
              statix.enable = true;
            };
            settings.excludes = [
              ".gitignore"
              "LICENSE"
              "flake.lock"
            ];
          }).config.build;
      in
      with pkgs;
      {
        checks.formatting = treefmt.check self;
        formatter = treefmt.wrapper;

        devShells.default = mkShellNoCC {
          packages = [ ];
        };
      }
    );
}
