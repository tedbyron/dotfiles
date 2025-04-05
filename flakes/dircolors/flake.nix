{
  description = "Dracula dircolors for home-manager";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "dracula-dircolors";
          version = src.rev;

          src = pkgs.fetchFromGitHub {
            owner = "dracula";
            repo = "dircolors";
            rev = "4d07e7ef1be615ccd2e91e1aa576a5b90d19a7dc";
            hash = "sha256-PzP+KW01NrlLeo0YQc/Wl+F2rUAtEZsrxjPTNhWyKPA=";
          };

          buildPhase = ''
            awk '
              BEGIN { print "{" }
              !(/^ *#/ || /TERM/) && NF { printf "  \"%s\" = \"%s\";\n", $1, $2 }
              END { print "}" }
            ' .dircolors > settings.nix
          '';

          installPhase = ''
            install -Dm644 settings.nix $out/share/nix/settings.nix
          '';
        };
      }
    );
}
