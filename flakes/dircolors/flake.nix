{
  description = "Dracula dircolors for home-manager";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "flake-utils";

    dracula-dircolors = {
      url = "github:dracula/dircolors";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      utils,
      dracula-dircolors,
      ...
    }:
    utils.lib.eachDefaultSystem (system: {
      packages.default = nixpkgs.legacyPackages.${system}.stdenvNoCC.mkDerivation rec {
        pname = "dracula-dircolors";
        version = src.rev;
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
    });
}
