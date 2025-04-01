{
  description = "Dracula dircolors for home-manager";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    nixpkgs-darwin.url = "nixpkgs/nixpkgs-24.11-darwin";
    flake-utils.url = "flake-utils";

    dracula-dircolors = {
      url = "github:dracula/dircolors";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-darwin,
      flake-utils,
      dracula-dircolors,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import (
          if
            builtins.elem system (
              with flake-utils.lib.system;
              [
                aarch64-darwin
                x86_64-darwin
              ]
            )
          then
            nixpkgs-darwin
          else
            nixpkgs
        ) { inherit system; };
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "dracula-dircolors";
          version = dracula-dircolors.rev;
          src = dracula-dircolors;

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
