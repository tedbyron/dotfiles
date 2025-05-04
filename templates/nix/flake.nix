{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "flake-utils";
    treefmt.url = "github:/numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      treefmt,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        treefmt =
          (self.inputs.treefmt-nix.lib.evalModule pkgs ({
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
          })).config.build;
      in
      with pkgs;
      {
        checks.formatting = treefmt.check self;
        formatter = treefmt.wrapper;
        devShells.default = mkShellNoCC { };
      }
    );
}
