{
  description = "Iosevka extended ss20 variant + nerd font glyphs";

  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    utils.url = "flake-utils";
  };

  outputs =
    {
      nixpkgs,
      utils,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;
        buildPlan = {
          family = "Curlio";
          spacing = "term";
          serifs = "sans";
          noCvSs = true;
          exportGlyphNames = false;

          variants = {
            inherits = "ss20";

            design = {
              capital-g = "toothless-corner-serifless-hooked";
              capital-j = "flat-hook-serifed";
              a = "single-storey-serifless";
              d = "toothed-serifless";
              e = "flat-crossbar";
              f = "flat-hook-serifless-crossbar-at-x-height";
              g = "single-storey-flat-hook-serifless";
              i = "hooky";
              j = "flat-hook-serifed";
              k = "curly-serifless";
              l = "hooky";
              r = "hookless-serifless";
              t = "flat-hook";
              u = "toothed-serifless";
              y = "cursive-flat-hook-serifless";

              long-s = "bent-hook-serifless";
              eszet = "sulzbacher-serifless";

              lower-iota = "serifed-flat-tailed";
              lower-tau = "flat-tailed";

              cyrl-u = "cursive-flat-hook-serifless";
              cyrl-ef = "serifless";
              cyrl-yeri = "corner";
              cyrl-yery = "corner";

              zero = "long-dotted";
              one = "base";
              four = "closed-serifless";
              five = "upright-flat-serifless";
              seven = "curly-serifless";

              asterisk = "penta-low";
              brace = "straight";
              at = "fourfold-solid-inner";
              dollar = "open";
              cent = "open";
              percent = "rings-continuous-slash";
              micro-sign = "toothed-serifless";

              lig-neq = "vertical";
              lig-equal-chain = "without-notch";
              lig-hyphen-chain = "without-notch";
            };
          };

          # https://github.com/be5invis/Iosevka/blob/main/doc/custom-build.md#configuring-ligations
          ligations = {
            inherits = "javascript";

            enables = [
              "center-op-influence-colon"
              "arrow-l"
              "hash-hash"
            ];

            disables = [
              "ltgt-slash-tag"
              "slash-asterisk"
            ];
          };

          widths = {
            normal = {
              shape = 600;
              menu = 5;
              css = "normal";
            };

            condensed = {
              shape = 500;
              menu = 3;
              css = "condensed";
            };
          };
        };
        buildPlanSingleWidth =
          width: buildPlan // { widths = lib.filterAttrs (name: _: name == width) buildPlan.widths; };

        all = pkgs.iosevka.override {
          set = "curlio";
          privateBuildPlan = buildPlan;
        };
        curlio = pkgs.iosevka.override {
          set = "curlio";
          privateBuildPlan = buildPlanSingleWidth "normal";
        };
        curlioCondensed = pkgs.iosevka.override {
          set = "curlio";
          privateBuildPlan = buildPlanSingleWidth "condensed";
        };

        mkFont =
          font: web:
          pkgs.stdenvNoCC.mkDerivation {
            inherit (font) name;
            dontUnpack = true;
            enableParallelBuilding = true;

            nativeBuildInputs =
              with pkgs;
              [ fd ]
              ++ (
                if web then
                  [
                    python312Packages.brotli
                    python312Packages.fonttools
                  ]
                else
                  [ nerd-font-patcher ]
              );

            buildPhase =
              if web then
                ''
                  # pyftsubset calls open with 'wb'
                  cp ${font}/share/fonts/truetype/*.ttf .

                  fd -j $NIX_BUILD_CORES -ettf . -x pyftsubset {} \
                    --output-file={.}.woff2 \
                    --flavor=woff2 \
                    --layout-features=* \
                    --desubroutinize \
                    --unicodes="U+0000-017F,U+2000-20CF,U+2100-22FF,U+FFFD"
                ''
              else
                ''
                  fd -j $NIX_BUILD_CORES -ettf . ${font}/share/fonts/truetype \
                    -x nerd-font-patcher {} --mono --careful --complete \
                    --adjust-line-height --makegroup -1
                '';

            installPhase =
              if web then
                ''
                  install -Dm444 ${font}/share/fonts/truetype/*.ttf \
                    -t $out/share/fonts/truetype
                  install -Dm444 *.woff2 -t $out/share/fonts/woff2
                ''
              else
                ''
                  install -Dm444 *.ttf -t $out/share/fonts/truetype
                '';
          };
      in
      {
        packages = rec {
          default = curlio-ttf;
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
