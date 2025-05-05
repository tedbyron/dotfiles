{
  pkgs,
  unstable,
  lib,
  darwin,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    localVariables.HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE = "1";
    syntaxHighlighting.enable = true;

    dirHashes =
      {
        dls = "$HOME/Downloads";
        dot = "$HOME/git/dotfiles";
        git = "$HOME/git";
      }
      // lib.optionalAttrs darwin {
        pub = "$HOME/Public";
      };

    history = {
      extended = true;
      # findNoDups = true; # TODO: 25.05
      ignoreAllDups = true;
      ignoreSpace = true;
      path = "$ZDOTDIR/.zsh_history";
      # saveNoDups = true; # TODO: 25.05
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

    initExtraBeforeCompInit = with unstable; ''
      . ${oh-my-zsh}/share/oh-my-zsh/lib/completion.zsh
      . ${oh-my-zsh}/share/oh-my-zsh/lib/correction.zsh
      . ${oh-my-zsh}/share/oh-my-zsh/lib/directories.zsh
      . ${oh-my-zsh}/share/oh-my-zsh/lib/history.zsh
      . ${oh-my-zsh}/share/oh-my-zsh/plugins/git-lfs/git-lfs.plugin.zsh
      . ${oh-my-zsh}/share/oh-my-zsh/plugins/git/git.plugin.zsh
      . ${oh-my-zsh}/share/oh-my-zsh/plugins/tmux/tmux.plugin.zsh

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
      b = "bat";
      cp = "cp -i";
      df = "df \\-h";
      dl = "yt-dlp";
      dls = "dl --embed-subs --sub-lang 'en.*'";
      dlx = "dl -x --audio-quality 0";
      du = "du \\-h -d 1";
      fcir = "fc -IR";
      fcl = "fc -lr";
      free = "free \\-h";
      gba = "git branch -avv";
      gbl = "git blame -wCCC";
      gbr = "git branch -rv";
      gdc = "git diff --check";
      gdcas = "gd diff --cached --stat";
      gds = "git diff --stat";
      gdst = "git diff --staged";
      gmv = "git mv";
      grep = "grep -Ei --color=auto";
      h = "head";
      hf = "hyperfine";
      j = "just";
      jg = "just -g";
      ls = "ls -FHh -I '.DS_Store' --color=auto --group-directories-first";
      la = "ls -A";
      l = "ls -Al";
      mv = "mv -i";
      nc = "ncat";
      pgrep = "pgrep -afil";
      ps = "ps -aefx";
      rm = "rm -i";
      sudo = "sudo ";
      t = "tail";
      tree = "unbuffer tree | bat -p";
      wlcopy = "wl-copy";
      wlpaste = "wl-paste";
    };

    shellGlobalAliases = {
      "-h" = "-h 2>&1 | bat -pl help";
      "--help" = "--help 2>&1 | bat -pl help";
    };

    sessionVariables = {
      EDITOR = "nvim";
      ERL_AFLAGS = "+pc unicode -kernel shell_history enabled";
      GOPATH = "$HOME/.go";
      IEX_HOME = "$HOME/.config/iex";
      LESS = "-FRi";
      LESSHISTFILE = "-";
      MANPAGER = "sh -c 'col -bx | bat -p -l man'";
      MANROFFOPT = "-c";
      NODE_REPL_HISTORY = " ";
      NULLCMD = ":";
      PAGER = "less";
      READNULLCMD = "bat";
      STARSHIP_LOG = "error";
      ZSH_TMUX_AUTOSTART = if darwin then "true" else "false";

      LS_COLORS =
        let
          configDir = if darwin then "./Library/Preferences" else "./.config";
        in
        ''
          mkdir -p ${configDir}/vivid/themes
          echo '${lib.ted.readConfig "vivid/themes/gruvbox-material-dark.yml"}' \
            > ${configDir}/vivid/themes/gruvbox-material-dark.yml
          HOME=. XDG_CONFIG_HOME=./.config vivid generate gruvbox-material-dark > $out
        ''
        |> pkgs.runCommandLocal "vivid-ls-colors" { nativeBuildInputs = [ pkgs.vivid ]; }
        |> builtins.readFile;
    };
  };
}
