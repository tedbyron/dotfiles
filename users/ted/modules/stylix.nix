{
  osConfig,
  pkgs,
  darwin,
  ...
}:
let
  wallpapers = [
    osConfig.stylix.image
    (pkgs.fetchurl {
      url = "https://codeberg.org/lunik1/nixos-logo-gruvbox-wallpaper/media/branch/master/png/gruvbox-light-blue.png";
      hash = "";
    })
    (pkgs.fetchurl {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/starry-sky.png";
      hash = "sha256-jbff7E63oDbU8vLdbCizjpbBPMEoWV934saNgBPEUEA=";
    })
    (pkgs.fetchurl {
      url = "https://gruvbox-wallpapers.pages.dev/wallpapers/minimalistic/gruvbox_grid.png";
      hash = "sha256-b7hN7xV/0a/7NVB3jLimPsaIO+ZLXGym7Hmvu5UsPoI=";
    })
  ];
in
{
  stylix = {
    enable = !darwin;
    image = builtins.head wallpapers;
    imageScalingMode = "fill";

    cursor = {
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      size = 12;
    };

    iconTheme = {
      enable = true;
      dark = "Gruvbox-Plus-Dark";
      light = "Gruvbox-Plus-Light";
      package = pkgs.gruvbox-plus-icons;
    };

    targets = {
      alacritty.enable = false;
      bat.enable = false;
      firefox.enable = false;
      fzf.enable = false;
      hyprland.enable = false;
      hyprpaper.enable = true;
      neovim.enable = false;
      spicetify.enable = false;
      vscode.enable = false;
      wofi.enable = false;
    };
  };
}
