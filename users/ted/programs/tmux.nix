{ unstable }:
{
  enable = true;
  clock24 = true;
  historyLimit = 50000;
  keyMode = "vi";
  mouse = true;
  newSession = true;
  prefix = "C-a";
  sensibleOnTop = false;
  terminal = "tmux-256color";

  extraConfig = ''
    set -g set-clipboard on
    set -g automatic-rename on
    set -g automatic-rename-format "#{?#{==:#{pane_current_command},zsh},#{?#{==:#{pane_current_path},#{HOME}},~,#{b:pane_current_path}},#{pane_current_command}}"
    set -g renumber-windows on
    set -as terminal-overrides ",alacritty:RGB"

    #

    set -sg escape-time 10
    set -g display-time 4000
    set -g status-interval 5
    set -g status-keys emacs
    set -g focus-events on
    setw -g aggressive-resize on

    bind C-p previous-window
    bind C-n next-window
    bind r source ~/.config/tmux/tmux.conf

    #

    bind c new-window -c "#{pane_current_path}"
    bind % split -h -c "#{pane_current_path}"
    bind '"' split -v -c "#{pane_current_path}"
  '';

  plugins = with unstable.tmuxPlugins; [
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
        set -g @dracula-transparent-powerline-bg true
        set -g @dracula-show-empty-plugins false

        # | Dracula color | Gruvbox color |
        # | ------------- | ------------- |
        # | white         | fg            |
        # | gray          | bg0_s         |
        # | dark_gray     | bg0           |
        # | dark_purple   | bg1           |
        # | cyan          | aqua          |
        # | pink          | purple 2      |
        set -g @dracula-colors "
        white='#ebdbb2'
        gray='#32302f'
        dark_gray='#282828'
        light_purple='#b16286'
        dark_purple='#3c3836'
        cyan='#689d6a'
        green='#98971a'
        orange='#d65d0e'
        red='#cc241d'
        pink='#d3869b'
        yellow='#d79921'
        "
      '';
    }
  ];
}
