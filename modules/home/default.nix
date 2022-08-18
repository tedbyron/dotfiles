{ lib, pkgs, ... }:
let inherit (pkgs.stdenvNoCC) isDarwin;
in
{
  imports = [
    ./git.nix
    ./options.nix
  ];

  home = {
    packages = with pkgs; [
      bat
      curl
      du-dust
      fd
      glab
      hyperfine
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
    bottom.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    exa.enable = true;
    gpg.enable = true;
    home-manager.enable = true;
    nix-index.enable = true;
    starship.enable = true;
    zsh.enable = true;
  };
}
