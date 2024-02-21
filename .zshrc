zstyle ':znap:*' repos-dir ~/.local/share/zsh-snap
zstyle ':znap:*:*' git-maintenance off
source ~/.local/share/zsh-snap/znap.zsh
znap eval starship 'starship init zsh --print-full-init'
znap prompt

if [[ "$(uname)" == 'Darwin' ]]; then
  export HOMEBREW_NO_ANALYTICS=1

  if [[ "$(arch)" == 'arm64' ]]; then
    znap eval brew '/opt/homebrew/bin/brew shellenv'
  else
    znap eval brew '/usr/local/bin/brew shellenv'
  fi

  if (( $+HOMEBREW_PREFIX )); then
    path=(
      "${HOMEBREW_PREFIX}/sbin"
      "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
      "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
      "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
      "${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
      $path
    )
  fi

  if [[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]]; then
    source "${HOME}/google-cloud-sdk/path.zsh.inc";
  fi
  if [[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]]; then
    source "${HOME}/google-cloud-sdk/completion.zsh.inc";
  fi

  export ZSH_TMUX_CONFIG="${HOME}/.config/tmux/tmux.conf"
fi

path=(
  "${HOME}/.cargo/bin"
  "${HOME}/.fly/bin"
  "${HOME}/.spicetify"
  $path
)

export BAT_THEME='Dracula'
export EDITOR='nvim'
export ERL_AFLAGS="-kernel shell_history enabled"
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
--color=dark
--color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
--color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
'
GPG_TTY="$(tty)"
export GPG_TTY
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
export MANPAGER="zsh -c 'col -bx | bat -l man -p'"
export STARSHIP_LOG=error
export SUDO_EDITOR='nvim'
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_FIXTERM=true

setopt auto_cd
setopt interactive_comments
setopt long_list_jobs
setopt multios
setopt no_beep

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

alias -g -- -h='-h 2>&1 | bat -pl help'
alias -g -- --help='--help 2>&1 | bat -pl help'
alias -- -='cd - > /dev/null'
alias df='df -h'
alias du='du -hd 1'
alias dust='dust -d 1'
alias gbl='git blame -wCCC'
alias grep='grep -Ei --color=auto'
alias h=history
alias less='less -FRi'
if (( $+commands[gls] )); then alias ls='gls'; fi
alias ls='ls -FHh --color=auto --group-directories-first'
alias la='ls -A'
alias l='ls -Al'
alias path='echo -e ${PATH//:/\\n}'
alias pgrep='pgrep -afil'
alias ps='ps -Aafx'
alias rg='rg -S'
alias sudo='sudo '
