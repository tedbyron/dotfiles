{ inputs, pkgs, unstable, lib, system, isDarwin }:
{
  alacritty = {
    enable = true;
    settings = fromTOML (builtins.readFile ../../../.config/alacritty/alacritty.toml);
  };

  bat = {
    enable = true;
    config.theme = "Dracula";
  };

  direnv = {
    enable = true;
    enableZshIntegration = true;
    # TODO: config, make timeout longer than 5s...
  };

  # eww

  firefox = {
    enable = !isDarwin;
    # TODO: config
  };

  fzf = {
    enable = true;
    changeDirWidgetCommand = "fd -HL -t d -E .git";
    enableZshIntegration = true;
    colors = {
      fg = "-1";
      bg = "-1";
      hl = "#50FA7B";
      "fg+" = "-1";
      "bg+" = "-1";
      "hl+" = "#FFB86C";
      info = "#BD93F9";
      prompt = "#50FA7B";
      pointer = "#FF79C6";
      marker = "#FF79C6";
      spinner = "#FF79C6";
    };
  };

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
  gpg.enable = true; # TODO: keys
  # home-manager.enable = true; #FIX: necessary?
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
    arguments = [ "-S" ];
  };

  spicetify = {
    enable = true;
    colorScheme = "Dracula";
    spotifyPackage = pkgs.spotify; # TODO: unstable
    theme = inputs.spicetify-nix.packages.${system}.default.themes.Sleek;
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

  zsh = import ./zsh.nix;
}
