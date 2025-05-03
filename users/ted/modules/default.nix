_: {
  imports = [
    ./hyprland.nix
  ];

  stylix.targets = {
    alacritty.enable = false;
    bat.enable = false;
    fzf.enable = false;
    hyprland.enable = false;
    neovim.enable = false;
    spicetify.enable = false;
    vscode.enable = false;
    wofi.enable = false;
  };
}
