zstyle ':znap:*' repos-dir ~/.local/share/zsh-snap
source ~/.local/share/zsh-snap/znap.zsh
if [[ "$(uname -s)" == 'Darwin' ]]; then
  if [[ "$(uname -m)" == 'arm64' ]]; then
    znap eval brew '/opt/homebrew/bin/brew shellenv'
  else
    znap eval brew '/usr/local/bin/brew shellenv'
  fi
fi
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# path
if [[ -v "${HOMEBREW_PREFIX}" ]]; then
  path=(
    "${HOMEBREW_PREFIX}/sbin"
    "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
    "${HOMEBREW_PREFIX}/opt/gnu-sed/libexec/gnubin"
    $path
  )
fi

path=(
  "${HOME}/.cargo/bin"
  "${HOME}/.spicetify"
  "${HOME}/.fly/bin"
  $path
)

if [[ -f "${HOME}/google-cloud-sdk/path.zsh.inc" ]]; then
  source "${HOME}/google-cloud-sdk/path.zsh.inc";
fi
if [[ -f "${HOME}/google-cloud-sdk/completion.zsh.inc" ]]; then
  source "${HOME}/google-cloud-sdk/completion.zsh.inc";
fi

# functions
znap fpath _rustup 'rustup completions zsh'
znap fpath _cargo 'rustup completions zsh cargo'

# exports
export EDITOR='nvim'
export SUDO_EDITOR='nvim'
export STARSHIP_LOG=error
export HOMEBREW_NO_ANALYTICS=1
GPG_TTY="$(tty)"
export GPG_TTY
export BAT_THEME='Dracula'
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_AUTOCONNECT=false
export ZSH_TMUX_FIXTERM=true
export ZSH_TMUX_CONFIG="${HOME}/.config/tmux/tmux.conf"

export LESS_TERMCAP_mb=$'\033[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\033[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\033[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\033[1;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\033[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\033[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\033[0m'        # reset underline

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"

export PNPM_HOME="${HOME}/Library/pnpm"
path=($PNPM_HOME $path)

# plugins
znap source ohmyzsh/ohmyzsh \
  lib/{completion,correction,directories,history} \
  plugins/{git,tmux}
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search

# zsh
setopt auto_cd
setopt interactive_comments
setopt long_list_jobs
setopt multios
setopt no_beep

bindkey -e
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey -M emacs '^ ' history-substring-search-up

# aliases
alias -- -='cd - > /dev/null'
alias up='brew update; brew upgrade; brew upgrade --cask; brew cleanup; \
rustup update; cargo install-update -a'
alias df='df -h'
alias du='du -hd 1'
alias dust='dust -d 1'
alias grep='grep -i --color=auto'
alias less='less -FRi'
alias ls='ls -Fh --color=auto --group-directories-first'
alias la='ls -A'
alias l='ls -lA'
alias path='echo -e ${PATH//:/\\n}'
alias pgrep='pgrep -fail'
alias ps='ps -ef'
alias rg='rg -S'
alias sudo='sudo '
