{ config, pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    bat
    cargo-binutils
    cargo-edit
    cargo-feature
    cargo-license
    coreutils
    curl
    direnv
    du-dust
    exa
    fd
    fzf
    gh
    git
    git-lfs
    glab
    jq
    ripgrep
    shellcheck
    tokei

    darwin-zsh-completions
  ];
  home.stateVersion = "22.11";

  programs.bash.enableCompletion = true;
  programs.direnv.enable = true;
  programs.nix-direnv.enable = true;
  programs.nix-index.enable = true;
  programs.starship.enable = true;
  programs.zsh.enable = true;
  programs.zsh.enableBashCompletion = true;
  programs.zsh.enableFzfCompletion = true;
  programs.zsh.enableFzfGit = true;
  programs.zsh.enableFzfHistory = true;
  programs.zsh.interactiveShellInit = '''';
  programs.zsh.loginShellInit = '''';
  programs.zsh.promptInit = '''';
  programs.zsh.variables.cfg = "$HOME/.config/nixpkgs/darwin-configuration.nix";
  programs.zsh.variables.darwin = "$HOME/.nix-defexpr/darwin";
  programs.zsh.variables.nixpkgs = "$HOME/.nix-defexpr/nixpkgs";
}
