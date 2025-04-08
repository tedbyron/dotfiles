{
  self,
  config,
  inputs,
  pkgs,
  unstable,
  lib,
  system,
  darwin,
  user,
}:
{
  alacritty = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ../../../.config/alacritty/alacritty.toml);
  };

  bat = {
    enable = true;

    config = {
      style = "changes,numbers";
      theme = "gruvbox-dark";
    };
  };

  dircolors = {
    enable = true;
    settings = import ("${self.outputs.packages.${system}.dircolors}/share/nix/settings.nix");
  };

  direnv = {
    enable = true;
    config = builtins.fromTOML (builtins.readFile ../../../.config/direnv/direnv.toml);
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  firefox = {
    enable = !darwin;
    # TODO: firefox config
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

  # TODO: once the darwin build is fixed
  # ghostty = {
  #   enable = true;
  #   enableZshIntegration = true;
  #   installBatSyntax = true;
  #   settings = builtins.fromTOML (builtins.readFile ../../../.config/ghostty/config);
  # };

  git = {
    enable = true;
    # delta configured in .gitconfig and installed as a user package
    extraConfig = builtins.fromTOML (builtins.readFile ../../../.config/git/config) // {
      credential.helper = if darwin then "osxkeychain" else "store";
    };
    ignores = lib.splitString "\n" (builtins.readFile ../../../.config/git/ignore);
    lfs.enable = true;
  };

  go = {
    enable = true;
    # telemetry.mode = "off"; # TODO: 25.05
  };

  gpg.enable = true; # TODO: gpg signing keys
  # home-manager.enable = true; # FIX: necessary?
  # jujutsu
  # keychain

  lazygit = {
    enable = true;
    settings = lib.ted.fromYAML (builtins.readFile ../../../.config/lazygit/config.yml);
  };

  neovim = {
    enable = true;
    package = unstable.neovim-unwrapped;
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
    arguments = lib.splitString "\n" (builtins.readFile ../../../.config/ripgrep/ripgreprc);
  };

  spicetify =
    let
      spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
    in
    {
      enable = true;
      colorScheme = "gruvbox";
      theme = spicePkgs.themes.text;
    };

  ssh.enable = true;

  starship = {
    enable = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (builtins.readFile ../../../.config/starship.toml);
  };

  tealdeer = {
    enable = true;
    settings = builtins.fromTOML (builtins.readFile ../../../.config/tealdeer/config.toml);
  };

  tmux = import ./tmux.nix { inherit unstable; };
  vscode.enable = true;
  yt-dlp.enable = true;

  zsh = import ./zsh.nix {
    inherit unstable lib darwin;
  };
}
