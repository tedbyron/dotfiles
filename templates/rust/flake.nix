{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
    treefmt.url = "github:/numtide/treefmt-nix";
    treefmt.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      utils,
      rust-overlay,
      treefmt,
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ (import rust-overlay) ];
        };
        rust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        treefmt =
          (self.inputs.treefmt-nix.lib.evalModule pkgs ({
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
          })).config.build;
      in
      with pkgs;
      {
        checks.formatting = treefmt.check self;
        formatter = treefmt.wrapper;
        devShells.default = mkShellNoCC { packages = [ rust ]; };
        packages.default = ""; # TODO
      }
    );
}
