{ pkgs, lib, isDarwin }: {
  enable = true;
  autocd = true;
  defaultKeymap = "emacs";
  dotDir = ".config/zsh";
  enableAutosuggestions = true;
  localVariables.HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE = "1";
  syntaxHighlighting.enable = true;

  dirHashes = {
    dot = "$HOME/git/dotfiles";
    git = "$HOME/git";
  } // lib.optionalAttrs isDarwin {
    dls = "$HOME/Downloads";
    pub = "$HOME/Public";
  };

  history = {
    path = "$ZDOTDIR/.zsh_history";

    ignorePatterns = [
      "> *"
      "builtin *"
      "kill *"
      "mkdir *"
      "pkill *"
      "rm *"
      "rmdir *"
      "touch *"
      "unlink *"
    ];
  };

  historySubstringSearch = {
    enable = true;

    searchUpKey = [ "^[[A" "^P" ];

    searchDownKey = [ "^[[B" "^N" ];
  };

  initExtraBeforeCompInit = ''
    . ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/completion.zsh
    . ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/correction.zsh
    . ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/directories.zsh
    . ${pkgs.oh-my-zsh}/share/oh-my-zsh/lib/history.zsh
    . ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git-lfs/git-lfs.plugin.zsh
    . ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh
    . ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/tmux/tmux.plugin.zsh

    setopt always_to_end
    setopt no_append_create
    setopt auto_pushd
    setopt no_beep
    setopt cd_silent
    setopt check_jobs
    setopt check_running_jobs
    setopt no_clobber
    setopt no_clobber_empty
    setopt combining_chars
    setopt complete_in_word
    setopt no_flow_control
    setopt long_list_jobs
    setopt pushd_minus
    setopt pushd_silent
    setopt pushd_to_home
    setopt multios
    setopt typeset_silent
  '';

  initExtra = ''
    bindkey -M menuselect '^[[Z' reverse-menu-complete

    # FIX 24-05
    alias -g -- -h='-h 2>&1 | bat -p -l help'
    alias -g -- --help='--help 2>&1 | bat -p -l help'
  '';

  shellAliases = {
    df = "df \\-h";
    du = "du \\-h -d 1";
    fcir = "fc -IR";
    fcl = "fc -lr";
    gba = "git branch -avv";
    gbl = "git blame -wCCC";
    gbr = "git branch -rv";
    gdc = "git diff --cached";
    grep = "grep -Ei --color=auto";
    grhh = "";
    gmv = "git mv";
    ls = if isDarwin then
      "ls -FHh -I '.DS_Store' --color=auto --group-directories-first"
    else
      "ls -FHh --color=auto --group-directories-first";
    la = "ls -A";
    l = "ls -Al";
    mv = "mv -i";
    pgrep = "pgrep -afil";
    ps = "ps -Aafx";
    sudo = "sudo ";
  };

  # FIX 24-05
  shellGlobalAliases = {
    # "-h" = "-h 2>&1 | bat -pl help";
    # "--help" = "--help 2>&1 | bat -pl help";
  };

  sessionVariables = {
    EDITOR = "nvim";
    ERL_AFLAGS = "+pc unicode -kernel shell_history enabled";
    IEX_HOME = "$HOME/.config/iex";
    LESS = "-FRi";
    LESSHISTFILE = "-";
    MANPAGER = "sh -c 'col -bx | bat -p -l man'";
    MANROFFOPT = "-c";
    NULLCMD = ":";
    PAGER = "less";
    READNULLCMD = "bat";
    STARSHIP_LOG = "error";
    ZSH_TMUX_AUTOSTART = "true";
  };
}
