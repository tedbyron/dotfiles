{ lib, pkgs, ... }:
let inherit (pkgs.stdenvNoCC) isDarwin;
in
{
  home = {
    packages = with pkgs; [
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
    ] ++ lib.optionals isDarwin [
      pinentry_mac
    ];
    stateVersion = "22.11";
  };

  programs = {
    direnv.enable = true;
    home-manager.enable = true;
    # nix-direnv.enable = true;
    nix-index.enable = true;
    starship.enable = true;
    zsh.enable = true;
  };
}
