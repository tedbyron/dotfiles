# Setup
zstyle ':znap:*' repos-dir ~/.local/share/zsh-snap
source ~/.local/share/zsh-snap/znap.zsh
znap eval starship 'starship init zsh --print-full-init'
znap prompt

function () {
  if [[ "$(uname)" == 'Darwin' ]]; then
    export HOMEBREW_NO_ANALYTICS=1

    if (( $#commands[(I)(darwin-rebuild)(home-manager)] == 0 )); then
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
        znap source "${HOME}/google-cloud-sdk/path.zsh.inc";
      fi
      if [[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]]; then
        znap source "${HOME}/google-cloud-sdk/completion.zsh.inc";
      fi
    fi
  fi
}

# Path
path=(
  "${HOME}/.cargo/bin"
  "${HOME}/.spicetify"
  "${HOME}/.fly/bin"
  $path
)

# Functions
znap fpath _rustup 'rustup completions zsh'
znap fpath _cargo 'rustup completions zsh cargo'

# Exports
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
export ZSH_TMUX_CONFIG="${HOME}/.config/tmux/tmux.conf"

# Zsh
znap source ohmyzsh/ohmyzsh \
  lib/{completion,correction,directories,history} \
  plugins/{git,tmux}
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search

setopt auto_cd
setopt interactive_comments
setopt long_list_jobs
setopt multios
setopt no_beep

bindkey -e
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# Aliases
alias -g -- -h='-h 2>&1 | bat -l help -p'
alias -g -- --help='--help 2>&1 | bat -l help -p'
alias -- -='cd - > /dev/null'
alias df='df -h'
alias du='du -hd 1'
alias dust='dust -d 1'
alias gbl='git blame -wCCC'
alias grep='egrep -i --color auto'
alias less='less -FRi'
if (( $+commands[gls] )); then alias ls='gls'; fi
alias ls='ls -FHh --color auto --group-directories-first'
alias la='ls -A'
alias l='ls -Al'
alias path='echo -e ${PATH//:/\\n}'
alias pgrep='pgrep -afil'
alias ps='ps -Aafx'
alias rg='rg -S'
alias sudo='sudo '
