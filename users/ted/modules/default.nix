_: {
  imports = [
    ./hyprland.nix
  ];

  stylix.targets = {
    neovim.enable = false;
    vscode.enable = false;
  };
}
