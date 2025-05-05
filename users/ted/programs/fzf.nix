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
      fg = "#d4be98";
      "fg+" = "#ddc7a1";
      hl = "#7daea3";
      "hl+" = "#7daea3";
      info = "#d8a657";
      marker = "#89b482";
      pointer = "#89b482";
      prompt = "#a9b665";
      spinner = "#89b482";
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
