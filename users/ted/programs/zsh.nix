{
  enable = true;
  autocd = true;
  defaultKeymap = "emacs";
  dirHashes = { };
  enableAutosuggestions = true;
  syntaxHighlighting.enable = true;

  history.ignorePatterns = [
    ".."
    "..."
    "...."
    "....."
    "......"

    "~"
    "-"
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"

    "cd *"
    "kill *"
    "pkill *"
    "rm *"
    "rmdir *"
    "unlink *"
  ];

  historySubstringSearch = {
    enable = true;
    searchUpKey = [
      "^[[A"
      "^P"
    ];
    searchDownKey = [
      "^[[B"
      "^N"
    ];
  };

  # FIX: hm 24-05
  initExtra = ''
    setopt always_to_end
    setopt auto_cd
    setopt auto_pushd
    setopt cd_silent
    setopt check_jobs
    setopt check_running_jobs
    setopt combining_chars
    setopt complete_in_word
    setopt pushd_silent
    setopt pushd_to_home
    setopt long_list_jobs
    setopt multios

    unsetopt append_create
    unsetopt clobber
    unsetopt clobber_empty
    unsetopt beep
    unsetopt flow_control

    alias -g -- -h='-h 2>&1 | bat -pl help'
    alias -g -- --help='--help 2>&1 | bat -pl help'
  '';

  # oh-my-zsh = {
  #   enable = false;
  #   plugins = [
  #     "git"
  #     "tmux"
  #   ];
  # };

  shellAliases = {
    df = "df -h";
    du = "du -hd 1";
    dust = "dust -d 1";
    fcir = "fc -IR";
    gba = "git branch -avv";
    gbl = "git blame -wCCC";
    gbr = "git branch -rv";
    grep = "grep -Ei --color=auto";
    ls = "ls -FHh --color=auto --group-directories-first";
    la = "ls -A";
    l = "ls -Al";
    nixpath = "echo -e \${NIX_PATH//:/\\n}";
    path = "echo -e \${PATH//:/\\n}";
    pgrep = "pgrep -afil";
    ps = "ps -Aafx";
    sudo = "sudo ";
  };
  # FIX: hm 24-05
  shellGlobalAliases = {
    # "-h" = "-h 2>&1 | bat -pl help";
    # "--help" = "--help 2>&1 | bat -pl help";
  };

  localVariables = {
    HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE = "1";
    READNULLCMD = "less";
    STARSHIP_LOG = "error";
    ZSH_TMUX_AUTOSTART = "true";
    ZSH_TMUX_FIXTERM = "true";
  };
  sessionVariables = {
    EDITOR = "nvim";
    ERL_AFLAGS = "-kernel shell_history enabled";
    # LESS = "-FRi";
    MANPAGER = "zsh -c \\\"col -bx | bat -p -l man\\\"";
    # PAGER = "less";
  };
}
