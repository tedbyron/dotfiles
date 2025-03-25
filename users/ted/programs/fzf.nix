{ config, user }:
{
  enable = true;
  changeDirWidgetCommand = "fd -HL -E .git -c always -t d --strip-cwd-prefix";
  defaultCommand = "fd -H -E .git -E .DS_Store -c always -t f --strip-cwd-prefix";
  enableZshIntegration = true;
  fileWidgetCommand = config.home-manager.users.${user}.programs.fzf.defaultCommand;
  historyWidgetOptions = [ "--layout reverse" ];

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

  defaultOptions = [
    "--ansi"
    "--info inline-right"
    "--no-scrollbar"
    "--no-separator"
  ];

  fileWidgetOptions = [
    "--preview 'bat --color always --style changes,numbers {}'"
    "--bind 'ctrl-/:change-preview-window(down|hidden|)'"
  ];
}
