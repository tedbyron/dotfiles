{ config, ... }:
{
  enable = true;

  autocd = true;
  defaultKeymap = "emacs";
  dotDir = ".config/zsh"; # relative to home directory
  enableAutosuggestions = true;
  enableCompletion = true;
  enableSyntaxHighlighting = true;

  history = {
    expireDuplicatesFirst = true;
    ignoreDups = true;
    path = "${config.xdg.dataHome}/zsh/zsh_history";
  };

  localVariables = { };
  # profileExtra = '''';
  sessionVariables = { };
  shellAliases = { };
  shellGlobalAliases = { };
}
