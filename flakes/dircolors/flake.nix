{
  description = "Dracula dircolors for home-manager";

  inputs = {
    nixpkgs = {
      type = "indirect";
      id = "nixpkgs";
    };

    flake-utils = {
      type = "indirect";
      id = "flake-utils";
    };

    dracula-dircolors = {
      url = "github:dracula/dircolors";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, dracula-dircolors }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "dracula-dircolors";
          version = dracula-dircolors.rev;
          src = dracula-dircolors;

          buildPhase = ''
            awk '
              BEGIN { print "{" }
              !(/^ *#/ || /TERM/) && NF { printf "  \"%s\" = \"%s\";\n",$1,$2 }
              END { print "}" }
            ' .dircolors > dircolors.nix
          '';

          installPhase = ''
            install -Dm644 dircolors.nix $out/share/nix/dircolors.nix
          '';
        };
      }
    );
}
