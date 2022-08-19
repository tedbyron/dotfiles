{ config, ... }:
{
  autocd = true;
  defaultKeymap = "viins";
  dotDir = ".config/zsh";
  enable = true;
  enableAutosuggestions = true;
  enableCompletion = true;
  enableSyntaxHighlighting = true;

  history = {
    expireDuplicatesFirst = true;
    ignoreDups = true;
    path = "${config.xdg.dataHome}/zsh/zsh_history";
  };

  localVariables = { };
  profileExtra = '''';
  sessionVariables = { };
  shellAliases = { };
  shellGlobalAliases = { };
}
