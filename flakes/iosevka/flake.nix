{
  description = "Iosevka extended ss20 variant + nerd font glyphs";

  inputs = {
    nixpkgs = {
      type = "indirect";
      id = "nixpkgs";
    };

    flake-utils = {
      type = "indirect";
      id = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        buildPlans = (fromTOML (builtins.readFile ./private-build-plans.toml)).buildPlans;

        all = pkgs.iosevka.override {
          set = "curlio";
          privateBuildPlan = buildPlans.curlio;
        };

        curlio = pkgs.iosevka.override {
          set = "curlio";

          privateBuildPlan = buildPlans.curlio // {
            widths = {
              normal = {
                shape = 600;
                menu = 5;
                css = "normal";
              };
            };
          };
        };

        curlioCondensed = pkgs.iosevka.override {
          set = "curlio-condensed";

          privateBuildPlan = buildPlans.curlio // {
            widths = {
              normal = {
                shape = 500;
                menu = 3;
                css = "condensed";
              };
            };
          };
        };

        mkFont = font: web:
          pkgs.stdenvNoCC.mkDerivation {
            name = "curlio";
            dontUnpack = true;

            nativeBuildInputs =
              if web then with pkgs; [
                python311Packages.brotli
                python311Packages.fonttools
              ] else with pkgs; [
                nerd-font-patcher
              ];

            buildPhase =
              if web then ''
                for ttf in ${font}/share/fonts/truetype/*.ttf; do
                  pyftsubset $ttf \
                    --output-file="$(basename $ttf .ttf)".woff2 \
                    --flavor=woff2 \
                    --layout-features=* \
                    --desubroutinize \
                    --unicodes="U+0000-0170,U+00D7,U+00F7,U+2000-206F,U+2074,U+20AC,U+2122,U+2190-21BB,U+2212,U+2215,U+F8FF,U+FEFF,U+FFFD,U+00E8"
                done
              '' else ''
                for ttf in ${font}/share/fonts/truetype/*.ttf; do
                  nerd-font-patcher -s -l -c --careful --makegroup -1 $ttf
                done
              '';

            installPhase =
              if web then ''
                install -Dt $out/share/fonts/truetype ${font}/share/fonts/truetype/*.ttf
                install -Dt $out/share/fonts/woff2 *.woff2
              '' else ''
                install -Dt $out/share/fonts/truetype *.ttf
              '';
          };
      in
      {
        packages = {
          all-ttf = mkFont all false;
          all-web = mkFont all true;
          curlio-ttf = mkFont curlio false;
          curlio-web = mkFont curlio true;
          curlio-condensed-ttf = mkFont curlioCondensed false;
          curlio-condensed-web = mkFont curlioCondensed true;
        };
      }
    );
}
