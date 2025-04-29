_: {
  imports = [
    ./hyprland.nix
  ];

  stylix.targets = {
    hyprland.enable = true;
    hyprpaper.enable = true;
    neovim.enable = false;
    vscode.enable = false;
  };
}
