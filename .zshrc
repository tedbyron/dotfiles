[[ ! -o interactive ]] && return

# set some env vars
eval "$(brew shellenv)"
eval "$(starship init zsh)"

# source antigen
source "${HOMEBREW_PREFIX}/share/antigen/antigen.zsh"

################################################################################
# Plugins
################################################################################

antigen use oh-my-zsh

#antigen bundle archlinux
#antigen bundle aws
antigen bundle brew
#antigen bundle debian
antigen bundle docker
antigen bundle fd
antigen bundle git
antigen bundle gh
#antigen bundle mongocli
#antigen bundle node
antigen bundle npm
#antigen bundle postgres
#antigen bundle pylint
antigen bundle python
antigen bundle ripgrep
#antigen bundle rsync
antigen bundle rust
#antigen bundle systemd
#antigen bundle ubuntu
#antigen bundle yarn # yarn 1 completions

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

brew_path="${HOMEBREW_PREFIX}/sbin"
coreutils_path="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
findutils_path="${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
grep_path="${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
node_path="${HOMEBREW_PREFIX}/opt/node@16/bin"
rust_path="${HOME}/.cargo/bin"
secrets_path="${HOME}/.secrets"

# add paths to $PATH if they exist and aren't in $PATH already
[[ -d "${brew_path}" && :"${PATH}": != *":${brew_path}:"* ]] \
&& export PATH="${brew_path}:${PATH}"
[[ -d "${coreutils_path}" && :"${PATH}": != *":${coreutils_path}:"* ]] \
&& export PATH="${coreutils_path}:${PATH}"
[[ -d "${findutils_path}" && :"${PATH}": != *":${findutils_path}:"* ]] \
&& export PATH="${findutils_path}:${PATH}"
[[ -d "${grep_path}" && :"${PATH}": != *":${grep_path}:"* ]] \
&& export PATH="${grep_path}:${PATH}"
[[ -d "${node_path}" && :"${PATH}": != *":${node_path}:"* ]] \
&& export PATH="${node_path}:${PATH}"
[[ -d "${rust_path}" && :"${PATH}": != *":${rust_path}:"* ]] \
&& export PATH="${rust_path}:${PATH}"
[[ -r "${secrets_path}" ]] && source "${secrets_path}"

# Don't source these variables
unset rust_path brew_path grep_path findutils_path coreutils_path node_path \
secrets_path

################################################################################
# Miscellaneous exports
################################################################################

export LDFLAGS="-L${HOMEBREW_PREFIX}/opt/node@16/lib"
export CPPFLAGS="-I${HOMEBREW_PREFIX}/opt/node@16/include"

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

# cd to parent directory
alias ..='cd ..'
# do everything except autoremove (orphaned dependencies)
alias brewup='brew update; brew upgrade; brew upgrade --cask; brew cleanup'
# human-readable
alias df='df -h'
# human-readable, max depth 1
alias du='du -hd 1'
# max depth 1
alias dust='dust -d 1'
# case insensitive, color
alias grep='grep -i --color=auto'
# quit if one screen, raw control chars
alias less='less -FR'
# classify entries, human-readable, color, directories first
alias ls='ls -Fh --color=auto --group-directories-first'
# almost all
alias la='ls -A'
# long list, almost all
alias ll='ls -lA'
# pretty print $PATH
alias path='echo -e ${PATH//:/\\n}'
# full match, include ancestors, ignore case, long output
alias pgrep='pgrep -fail'
# all processes, full format
alias ps='ps -ef'
# smart letter case
alias rg='rg -S'
# expand aliases used with sudo
alias sudo='sudo '
# nvim if exists
if (( ${+commands[nvim]} )); then
  alias vim='nvim'
  alias v='nvim'
fi
