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
        inherit (pkgs) lib;

        pkgs = import nixpkgs { inherit system; };

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
              four = "closed";
              five = "upright-flat";
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
            disables = [ "ltgt-slash-tag" ];

            enables = [
              "center-op-influence-colon"
              "arrow-l"
              "slash-asterisk"
              "hash-hash"
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

        all = pkgs.iosevka.override {
          set = "curlio";
          privateBuildPlan = buildPlan;
        };

        buildPlanSingleWidth = width: buildPlan // {
          widths = lib.filterAttrs (name: _: name == width) buildPlan.widths;
        };

        curlio = pkgs.iosevka.override {
          set = "curlio";
          privateBuildPlan = buildPlanSingleWidth "normal";
        };

        curlioCondensed = pkgs.iosevka.override {
          set = "curlio";
          privateBuildPlan = buildPlanSingleWidth "condensed";
        };

        mkFont = font: web:
          pkgs.stdenvNoCC.mkDerivation {
            name = font.name;
            dontUnpack = true;

            nativeBuildInputs = with pkgs; [
                fd
              ] ++ (if web then [
                python311Packages.brotli
                python311Packages.fonttools
              ] else [
                nerd-font-patcher
              ]);

            buildPhase =
              if web then ''
                # pyftsubset calls open with 'wb'
                cp ${font}/share/fonts/truetype/*.ttf .

                fd -j$NIX_BUILD_CORES -ettf . -x pyftsubset {} \
                  --output-file={.}.woff2 \
                  --flavor=woff2 \
                  --layout-features=* \
                  --desubroutinize \
                  --unicodes="U+0000-0170,U+00D7,U+00F7,U+2000-206F,U+2074,U+20AC,U+2122,U+2190-21BB,U+2212,U+2215,U+F8FF,U+FEFF,U+FFFD,U+00E8"
              '' else ''
                fd -j$NIX_BUILD_CORES -ettf . ${font}/share/fonts/truetype -x nerd-font-patcher {} \
                  --mono --careful --complete --adjust-line-height --makegroup -1
              '';

            installPhase =
              if web then ''
                install -Dm444 ${font}/share/fonts/truetype/*.ttf -t $out/share/fonts/truetype
                install -Dm444 *.woff2 -t $out/share/fonts/woff2
              '' else ''
                install -Dm444 *.ttf -t $out/share/fonts/truetype
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
