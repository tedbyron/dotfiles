{
  config,
  pkgs,
  unstable,
  lib,
  darwin,
  ...
}:
let
  home = config.home.homeDirectory;
  configHome = config.xdg.configHome;
in
{
  programs.zsh = {
    enable = true;
    autocd = true;
    autosuggestion.enable = true;
    defaultKeymap = "emacs";
    dotDir = ".config/zsh";
    localVariables.HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE = "1";
    syntaxHighlighting.enable = true;

    dirHashes = {
      dls = "${home}/Downloads";
      dot = "${home}/git/dotfiles";
      git = "${home}/git";
    }
    // lib.optionalAttrs darwin {
      pub = "${home}/Public";
    };

    history = {
      extended = true;
      findNoDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      path = "$ZDOTDIR/.zsh_history";
      saveNoDups = true;
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

    initContent = lib.mkMerge [
      (lib.mkOrder 550 (
        with unstable;
        ''
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
        ''
      ))

      (lib.mkOrder 1000 ''
        bindkey -M menuselect '^[[Z' reverse-menu-complete
        bindkey \^U backward-kill-line

        unalias grhh
      '')
    ];

    shellAliases = {
      b = "bat";
      cp = "cp -i";
      date = "date -u +\"%Y-%m-%dT%H:%M:%SZ\"";
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
      gdss = "git diff --shortstat";
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
      n = "nvim";
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
      "-h" = "-h |& bat -pl help";
      "--help" = "--help |& bat -pl help";
    };

    sessionVariables = {
      EDITOR = "nvim";
      ERL_AFLAGS = "+pc unicode -kernel shell_history enabled";
      GOPATH = "${home}/.go";
      IEX_HOME = "${configHome}/iex";
      LESS = "-FRi";
      LESSHISTFILE = "-";
      MANPAGER = "sh -c 'col -bx | bat -p -l man'";
      MANROFFOPT = "-c";
      NODE_REPL_HISTORY = " ";
      NULLCMD = ":";
      PAGER = "less";
      PYTHONSTARTUP = "${configHome}/python/pythonrc.py";
      READNULLCMD = "bat";
      STARSHIP_LOG = "error";
      ZSH_TMUX_AUTOSTART = if darwin then "true" else "false";

      LS_COLORS =
        let
          configDir = ".config/vivid/themes";
        in
        ''
          mkdir -p ${configDir}
          echo '${lib.ted.readConfig "vivid/themes/gruvbox-material-dark.yml"}' \
            > ${configDir}/gruvbox-material-dark.yml
          HOME=. vivid generate gruvbox-material-dark > $out
        ''
        |> pkgs.runCommandLocal "vivid-ls-colors" { nativeBuildInputs = [ pkgs.vivid ]; }
        |> builtins.readFile;
    };
  };
}
