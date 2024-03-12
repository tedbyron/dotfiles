{ inputs, pkgs, unstable, lib, system, isDarwin }:
{
  alacritty = {
    enable = true;
    settings = fromTOML (builtins.readFile ../../../.config/alacritty/alacritty.toml);
  };

  bat = {
    enable = true;

    config = {
      style = "changes,numbers";
      theme = "Dracula";
    };
  };

  dircolors = {
    enable = true;
    # TODO dircolors: config
  };

  direnv = {
    enable = true;
    enableZshIntegration = true;
    # TODO direnv: make timeout longer than 5s...
  };

  # eww

  firefox = {
    enable = !isDarwin;
    # TODO firefox: config
  };

  fzf = import ./fzf.nix;

  gh = {
    enable = true;
    gitCredentialHelper.enable = true;

    settings = {
      git_protocol = "https";
      editor = "nvim";
      aliases = {
        prco = "pr checkout";
        open = "repo view --web";
      };
    };
  };

  # gh-dash

  git = {
    enable = true;
    # delta configured in .gitconfig and installed as a user package
    extraConfig = fromTOML (builtins.readFile ../../../.gitconfig);
    ignores = [ ".DS_Store" ];
    lfs.enable = true;
  };

  # git-cliff
  # go
  gpg.enable = true; # TODO gpg: signing keys
  # home-manager.enable = true; #FIX necessary?
  # jujutsu
  # keychain

  man = {
    generateCaches = true;
  };

  neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;
  };

  pandoc.enable = true;

  ripgrep = {
    enable = true;

    arguments = [
      "-."
      "-S"
      "-g=!.git"
    ];
  };

  spicetify =
    let spicePkgs = inputs.spicetify-nix.packages.${system}.default;
    in {
      enable = true;
      colorScheme = "Dracula";
      spotifyPackage = pkgs.spotify; # TODO spotify: unstable
      theme = spicePkgs.themes.Sleek;
    };

  # sqls
  ssh.enable = true;

  starship = {
    enable = true;
    enableZshIntegration = true;
    settings = fromTOML (builtins.readFile ../../../.config/starship.toml);
  };

  tmux = import ./tmux.nix { inherit pkgs lib; };

  yt-dlp = {
    enable = true;

    settings = {
      embed-chapters = true;
      embed-thumbnail = true;
      embed-subs = true;
      sub-langs = "en";
    };
  };

  zsh = import ./zsh.nix { inherit pkgs lib isDarwin; };
}
