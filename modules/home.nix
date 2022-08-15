{ config, lib, pkgs, ... }: {
  home.packages = with pkgs; [
    bat
    bottom
    curl
    delta
    direnv
    du-dust
    exa
    fd
    fzf
    gh
    git
    git-lfs
    glab
    gnupg
    jq
    ripgrep
    shellcheck
    tokei
  ] ++ lib.optionals stdenvNoCC.isDarwin [
    pinentry_mac
  ];

  programs.direnv.enable = true;
  programs.home-manager.enable = true;
  programs.nix-direnv.enable = true;
  programs.nix-index.enable = true;
  programs.starship.enable = true;
  programs.zsh.enable = true;
}
