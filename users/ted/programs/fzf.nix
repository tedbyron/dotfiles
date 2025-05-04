{ config, ... }:
{
  programs.fzf = {
    enable = true;
    changeDirWidgetCommand = "fd -HL -E .git -c always -t d --strip-cwd-prefix";
    defaultCommand = "fd -H -E .git -E .DS_Store -c always -t f --strip-cwd-prefix";
    enableZshIntegration = true;
    fileWidgetCommand = config.programs.fzf.defaultCommand;
    historyWidgetOptions = [ "--layout reverse" ];

    colors = {
      bg = "#282828";
      "bg+" = "#3c3836";
      fg = "#bdae93";
      "fg+" = "#ebdbb2";
      hl = "#83a598";
      "hl+" = "#83a598";
      info = "#fabd2f";
      marker = "#8ec07c";
      pointer = "#8ec07c";
      prompt = "#fabd2f";
      spinner = "#8ec07c";
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
      "--bind 'ctrl-b:preview-page-up,ctrl-f:preview-page-down'"
      "--bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'"
    ];
  };
}
