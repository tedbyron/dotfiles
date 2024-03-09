{ inputs, pkgs, unstable, system, isDarwin }:
let
  inherit (inputs) spicetify-nix;

  spicePkgs = spicetify-nix.packages.${system}.default;
in
{
  alacritty = {
    enable = true;
    settings = fromTOML (builtins.readFile ../../.config/alacritty/alacritty.toml);
  };

  bat = {
    enable = true;
    config = {
      pager = "less -FRi";
      theme = "Dracula";
    };
  };

  direnv = {
    enable = true;
    enableZshIntegration = true;
    # TODO: config
  };

  # eww

  firefox = {
    enable = !isDarwin;
    # TODO: config
  };

  fzf = {
    enable = true;
    enableZshIntegration = true;
    # TODO: config
  };

  gh = {
    enable = true;
    gitCredentialHelper.enable = true;

    settings = {
      git_protocol = "https";
      editor = "nvim";

      aliases = {
        prc = "pr checkout";
        open = "repo view --web";
      };
    };
  };

  # gh-dash

  git = {
    enable = true;
    # delta configured in .gitconfig and installed as a user package
    extraConfig = fromTOML (builtins.readFile ../../.gitconfig);
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
    spotifyPackage = unstable.spotify;
    theme = spicePkgs.themes.Sleek;
  };

  # sqls
  ssh.enable = true;

  starship = {
    enable = true;
    enableZshIntegration = true;
    settings = fromTOML (builtins.readFile ../../.config/starship.toml);
  };

  tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    mouse = true;
    newSession = true;
    shell = "${pkgs.zsh}/bin/zsh";
    shortcut = "a";

    extraConfig = ''
      set -g set-clipboard on
      set -g automatic-rename on
      set -g automatic-rename-format "#{?#{==:#{pane_current_command},zsh},#{?#{==:#{pane_current_path},#{HOME}},~,#{b:pane_current_path}},#{pane_current_command}}"
      set -sa terminal-overrides ",alacritty:RGB"
      set -ga terminal-overrides ',alacritty:Tc'

      bind c new-window -c "#{pane_current_path}"
      bind % split -h -c "#{pane_current_path}"
      bind '"' split -v -c "#{pane_current_path}"
    '';

    plugins = with pkgs.tmuxPlugins; [
      sensible

      {
        plugin = dracula;
        extraConfig = ''
          set -g @dracula-plugins "ssh-session attached-clients"
          set -g @dracula-ssh-session-colors "dark_purple white"
          set -g @dracula-attached-clients-colors "green dark_gray"
          set -g @dracula-show-flags false
          set -g @dracula-show-left-icon session
          set -g @dracula-border-contrast false
          set -g @dracula-military-time true
          set -g @dracula-show-empty-plugins false
        '';
      }
    ];
  };

  vscode = {
    enable = true;
    package = unstable.vscode;
  };

  yt-dlp = {
    enable = true;
    settings = {
      embed-chapters = true;
      embed-thumbnail = true;
      embed-subs = true;
      sub-langs = "en";
    };
  };

  zsh = {
    enable = true;
  };
}
