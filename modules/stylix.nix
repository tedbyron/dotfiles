{ self, pkgs, ... }:
{
  stylix = {
    enable = true;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-material-dark-medium.yaml";
    polarity = "dark";

    fonts = {
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
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/gruvbox-nix.png";
      hash = "sha256-WuLGBomGcJxDgHWIHNN2qyqCzltvo45PiT062ZwAQ6I=";
    };
  };
}
