zstyle ':znap:*' repos-dir ~/.local/share/zsh-snap
source ~/.local/share/zsh-snap/znap.zsh
[[ "$TERM_PROGRAM" == "iTerm.app" ]] \
  && znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'
znap eval brew '/opt/homebrew/bin/brew shellenv'
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# plugins

znap source ohmyzsh/ohmyzsh \
  lib/{completion,correction,directories,history} \
  plugins/git
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-history-substring-search
# must be last: https://github.com/zsh-users/zsh-syntax-highlighting#faq
znap source zsh-users/zsh-syntax-highlighting

# zsh

setopt auto_cd
setopt interactive_comments
setopt long_list_jobs
setopt multios
setopt no_beep

bindkey -e
bindkey '^ ' autosuggest-accept

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# path

path=(
  "${HOMEBREW_PREFIX}/sbin"
  "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
  "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
  "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
  "${HOME}/.cargo/bin"
  $path
)

# functions

znap fpath _rustup 'rustup completions zsh'
znap fpath _cargo 'rustup completions zsh cargo'

# misc exports

export STARSHIP_LOG=error
export HOMEBREW_NO_ANALYTICS=1

GPG_TTY="$(tty)"
export GPG_TTY

export LESS_TERMCAP_mb=$'\033[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\033[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\033[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\033[1;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\033[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\033[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\033[0m'        # reset underline

export EDITOR='nvim'
export SUDO_EDITOR='nvim'

export BAT_THEME='Dracula'

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

export PNPM_HOME="/Users/ted/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# aliases

alias up='brew update; brew upgrade; brew upgrade --cask; brew cleanup; \
rustup update; cargo install-update -a'
alias df='df -h'
alias du='du -hd 1'
alias dust='dust -d 1'
alias grep='grep -i --color=auto'
alias less='less -FR'
alias ls='ls -Fh --color=auto --group-directories-first'
alias la='ls -A'
alias l='ls -lA'
alias path='echo -e ${PATH//:/\\n}'
alias pgrep='pgrep -fail'
alias ps='ps -ef'
alias rg='rg -S'
alias sudo='sudo '
