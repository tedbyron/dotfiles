{
  self,
  pkgs,
  lib,
  darwin,
  ...
}:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
    polarity = "dark";

    fonts = lib.optionalAttrs (!darwin) {
      monospace = {
        name = "Curlio";
        package = self.outputs.packages.${pkgs.system}.curlio-ttf;
      };
      sansSerif = {
        name = "Inter";
        package = pkgs.inter;
      };
      serif = {
        name = "Libre Baskerville";
        package = pkgs.libre-baskerville;
      };
      emoji = {
        name = "Apple Color Emoji";
        package = self.inputs.apple-emoji-linux.outputs.packages.${pkgs.system}.default;
      };
    };

    image = pkgs.fetchurl {
      url = "https://codeberg.org/lunik1/nixos-logo-gruvbox-wallpaper/media/branch/master/png/gruvbox-dark-blue.png";
      hash = "sha256-+jfTuvl1VJocN+YNp04YVONR054GX+p/yxNXyyhsNcs=";
    };
  };
}
