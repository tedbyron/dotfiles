{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    treefmt.url = "github:/numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, ... }@inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [ (import inputs.rust-overlay) ];
        };
        rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        treefmt =
          (inputs.treefmt.lib.evalModule pkgs {
            programs = {
              deadnix.enable = true;
              nixfmt.enable = true;
              rustfmt.enable = true;
              statix.enable = true;
              taplo.enable = true;
              prettier = {
                enable = true;
                settings = {
                  proseWrap = "always";
                  semi = false;
                  singleQuote = true;
                  trailingComma = "all";
                  overrides = [
                    {
                      files = "*.yml";
                      options.singleQuote = false;
                    }
                  ];
                };
              };
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
          packages = [ rust ];
        };

        packages.default = ""; # TODO
      }
    );
}
