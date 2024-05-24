{
  self,
  config,
  inputs,
  pkgs,
  unstable,
  lib,
  system,
  isDarwin,
  user,
}:
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
    settings = import ("${self.outputs.packages.${system}.dircolors}/share/nix/settings.nix");
  };

  direnv = {
    enable = true;
    config = fromTOML (builtins.readFile ../../../.config/direnv/direnv.toml);
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # eww

  firefox = {
    enable = !isDarwin;
    # TODO firefox: config
  };

  fzf = import ./fzf.nix { inherit config user; };

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

  git = {
    enable = true;
    # delta configured in .gitconfig and installed as a user package
    extraConfig = fromTOML (builtins.readFile ../../../.config/git/config);
    ignores = lib.splitString "\n" (builtins.readFile ../../../.config/git/ignore);
    lfs.enable = true;
    package = unstable.git; # FIX 24-05
  };

  # go
  gpg.enable = true; # TODO gpg: signing keys
  # home-manager.enable = true; #FIX necessary?
  # jujutsu
  # keychain
  man.generateCaches = true;

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
    let
      spicePkgs = inputs.spicetify-nix.packages.${system}.default;
    in
    {
      enable = true;
      colorScheme = "Dracula";
      spotifyPackage = unstable.spotify;
      theme = spicePkgs.themes.Sleek;
    };

  # sqls
  ssh.enable = true;

  starship = {
    enable = true;
    enableZshIntegration = true;
    settings = fromTOML (builtins.readFile ../../../.config/starship.toml);
  };

  tmux = import ./tmux.nix { inherit pkgs; };
  vscode.enable = true;

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
