typeset -U PATH path CDPATH cdpath FPATH fpath MANPATH manpath

zstyle ':znap:*' repos-dir ~/.local/share/zsh-snap
zstyle ':znap:*:*' git-maintenance off
. ~/.local/share/zsh-snap/znap.zsh
znap eval starship 'starship init zsh --print-full-init'
znap prompt

HISTORY_IGNORE='(..|...|....|.....|......|~|-|1|2|3|4|5|6|7|8|9|> *|builtin *|cd *|kill *|mkdir *|pkill *|rm *|rmdir *|touch *|unlink *)'

is_darwin=$([[ "$(uname)" == 'Darwin'* ]])
if ($is_darwin) {
  export HOMEBREW_NO_ANALYTICS=1

  if [[ "$(arch)" == 'arm64'* ]] {
    znap eval brew '/opt/homebrew/bin/brew shellenv'
  } else {
    znap eval brew '/usr/local/bin/brew shellenv'
  }

  if (( $+HOMEBREW_PREFIX )) {
    path+=(
      $HOMEBREW_PREFIX/sbin
      $HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin
      $HOMEBREW_PREFIX/opt/findutils/libexec/gnubin
      $HOMEBREW_PREFIX/opt/grep/libexec/gnubin
      $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
    )
  }

  if [[ -f $HOME/google-cloud-sdk/path.zsh.inc ]] {
    . $HOME/google-cloud-sdk/path.zsh.inc
  }
  if [[ -f $HOME/google-cloud-sdk/completion.zsh.inc ]] {
    . $HOME/google-cloud-sdk/completion.zsh.inc
  }

  export ZSH_TMUX_CONFIG=$HOME/.config/tmux/tmux.conf
}

path+=(
  $HOME/.cargo/bin
  $HOME/.fly/bin
  $HOME/.spicetify
)

export BAT_THEME=Dracula
export EDITOR=nvim
export ERL_AFLAGS='+pc unicode -kernel shell_history enabled'
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=fg:-1,bg:-1,hl:#50FA7B,fg+:-1,bg+:-1,hl+:#FFB86C
--color=info:#BD93F9,prompt:#50FA7B,pointer:#FF79C6,marker:#FF79C6,spinner:#FF79C6
'
export GPG_TTY="$(tty)"
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
export LESS=-FRi
export MANPAGER='zsh -c "col -bx | bat -p -l man"'
export MANROFFOPT=-c
export NULLCMD=:
export PAGER=less;
export READNULLCMD=bat
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/ripgreprc
export STARSHIP_LOG=error
export ZSH_TMUX_AUTOSTART=true

setopt always_to_end
setopt no_append_create
setopt auto_cd
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

znap source ohmyzsh/ohmyzsh \
  lib/{completion,correction,directories,history} \
  plugins/{git,tmux}
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search

znap fpath _rustup 'rustup completions zsh'
znap fpath _cargo 'rustup completions zsh cargo'

bindkey -e
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey -M menuselect '^[[Z' reverse-menu-complete

alias df='df -h'
alias du='du -h -d 1'
alias dust='dust -d 1'
alias fcir='fc -IR'
alias gba='git branch -avv'
alias gbl='git blame -wCCC'
alias gbr='git branch -rv'
alias grhh=
alias grep='grep -Ei --color=auto'
if (( $+commands[gls] )) alias ls=gls
if ($is_darwin) {
  alias ls='ls -FHh -I ".DS_Store" --color=auto --group-directories-first'
} else {
  alias ls='ls -FHh --color=auto --group-directories-first'
}
alias la='ls -A'
alias l='ls -Al'
alias pgrep='pgrep -afil'
alias ps='ps -Aafx'
alias rg='rg -.S -g "!.git"'
alias sudo='sudo '

alias -g -- -h='-h 2>&1 | bat -p -l help'
alias -g -- --help='--help 2>&1 | bat -p -l help'

hash -d dot=$HOME/git/dotfiles
hash -d git=$HOME/git
if ($is_darwin) {
  hash -d dls=$HOME/Downloads
  hash -d pub=$HOME/Public
}

unset is_darwin
