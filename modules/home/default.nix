{ config, lib, pkgs, ... }:
let inherit (pkgs.stdenvNoCC) isDarwin;
in
{
  imports = [ ./options.nix ];

  home = {
    packages = with pkgs; [
      curl
      du-dust
      fd
      glab
      hyperfine
      ripgrep
      shellcheck
      tokei
    ] ++ lib.optionals isDarwin [ pinentry_mac ];

    stateVersion = "22.11";
  };

  programs = {
    # alacritty = import ./alacritty.nix;

    bat = {
      config.theme = "Dracula";
      enable = true;
    };

    bottom.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    # eww = {
    #   configDir = ../../eww;
    #   enable = true;
    # };

    exa.enable = true;

    gh = {
      enable = true;
      extensions = [ pkgs.gh-dash ];
    };

    git = import ./git.nix { inherit config pkgs; };
    gpg.enable = true;
    home-manager.enable = true;
    jq.enable = true;
    just.enable = true;
    man.enable = true;
    navi.enable = true;

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };

    nix-index.enable = true;
    starship = import ./starship.nix;
    # tmux = import ./tmux.nix;
    zsh = import ./zsh.nix { inherit config; };
  };

  targets.darwin.search = "DuckDuckGo";
}
