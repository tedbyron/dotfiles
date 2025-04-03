{
  unstable,
  lib,
  darwin,
}:
{
  enable = true;
  autocd = true;
  autosuggestion.enable = true;
  defaultKeymap = "emacs";
  dotDir = ".config/zsh";
  history.path = "$ZDOTDIR/.zsh_history";
  localVariables.HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE = "1";
  syntaxHighlighting.enable = true;

  dirHashes =
    {
      dot = "$HOME/git/dotfiles";
      git = "$HOME/git";
    }
    // lib.optionalAttrs darwin {
      dls = "$HOME/Downloads";
      pub = "$HOME/Public";
    };

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

  initExtraBeforeCompInit = ''
    . ${unstable.oh-my-zsh}/share/oh-my-zsh/lib/completion.zsh
    . ${unstable.oh-my-zsh}/share/oh-my-zsh/lib/correction.zsh
    . ${unstable.oh-my-zsh}/share/oh-my-zsh/lib/directories.zsh
    . ${unstable.oh-my-zsh}/share/oh-my-zsh/lib/history.zsh
    . ${unstable.oh-my-zsh}/share/oh-my-zsh/plugins/git-lfs/git-lfs.plugin.zsh
    . ${unstable.oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh
    . ${unstable.oh-my-zsh}/share/oh-my-zsh/plugins/tmux/tmux.plugin.zsh

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
    bindkey \^U backward-kill-line

    unalias grhh
  '';

  shellAliases = {
    df = "df \\-h";
    dl = "yt-dlp";
    dls = "dl --embed-subs --sub-lang 'en.*'";
    dlx = "dl -x --audio-quality 0";
    du = "du \\-h -d 1";
    fcir = "fc -IR";
    fcl = "fc -lr";
    gba = "git branch -avv";
    gbl = "git blame -wCCC";
    gbr = "git branch -rv";
    gdc = "git diff --check";
    gds = "git diff --stat";
    gdst = "git diff --staged";
    gmv = "git mv";
    grep = "grep -Ei --color=auto";
    hf = "hyperfine";
    ls = "ls -FHh -I '.DS_Store' --color=auto --group-directories-first";
    la = "ls -A";
    l = "ls -Al";
    mv = "mv -i";
    nc = "ncat";
    pgrep = "pgrep -afil";
    ps = "ps -Aafx";
    sudo = "sudo ";
  };

  shellGlobalAliases = {
    "-h" = "-h 2>&1 | bat -pl help";
    "--help" = "--help 2>&1 | bat -pl help";
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
