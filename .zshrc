[[ ! -o interactive ]] && return

# set some env vars
eval "$(/opt/homebrew/bin/brew shellenv)"
eval "$(starship init zsh)"

# source antigen
source "${HOMEBREW_PREFIX}/share/antigen/antigen.zsh"

################################################################################
# Plugins
################################################################################

antigen use oh-my-zsh

antigen bundle brew
antigen bundle fd
antigen bundle git
antigen bundle gh
antigen bundle mix
antigen bundle node
antigen bundle npm
antigen bundle nvm
antigen bundle ripgrep
antigen bundle rust
antigen bundle yarn

antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-history-substring-search
# must be last: https://github.com/zsh-users/zsh-syntax-highlighting#faq
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

################################################################################
# Keybinds
################################################################################

# emacs mode
bindkey -e
# zsh-autosuggestions
bindkey '^ ' autosuggest-accept

# zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

################################################################################
# Path exports
################################################################################

path=(
  "${HOMEBREW_PREFIX}/sbin"
  "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
  "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
  "${HOMEBREW_PREFIX}/opt/llvm/bin"
  "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
  "${HOME}/.config/emacs/bin"
  "${HOME}/.cargo/bin"
  $path
)

################################################################################
# Miscellaneous exports
################################################################################

export HOMEBREW_NO_ANALYTICS=1

export BAT_THEME='Dracula'

GPG_TTY="$(tty)"
export GPG_TTY

export LESS_TERMCAP_mb=$'\033[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\033[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\033[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\033[1;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\033[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\033[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\033[0m'        # reset underline

if (( ${+commands[nvim]} )); then
  export EDITOR='nvim'
  export SUDO_EDITOR='nvim'
elif (( ${+commands[vim]} )); then
  export EDITOR='vim'
  export SUDO_EDITOR='vim'
else
  export EDITOR='vi'
  export SUDO_EDITOR='vi'
fi

################################################################################
# Aliases
################################################################################

alias brewup='brew update; brew upgrade; brew upgrade --cask; brew cleanup'
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
if (( ${+commands[nvim]} )); then
  alias vim='nvim'
  alias v='nvim'
fi
