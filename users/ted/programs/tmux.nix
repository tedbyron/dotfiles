{ pkgs, lib }:
{
  enable = true;
  clock24 = true;
  keyMode = "vi";
  mouse = true;
  newSession = true;
  shell = "${lib.getBin pkgs.zsh}/bin/zsh";
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
}
