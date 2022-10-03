# shellcheck disable=SC2148,SC1091

[[ -z "${PS1}" ]] && return

eval "$(starship init bash)"

################################################################################
# path additions
################################################################################

coreutils_path="${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
findutils_path="${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
grep_path="${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
brew_path="${HOMEBREW_PREFIX}/sbin"
rust_path="${HOME}/.cargo/bin"
node_path="${HOMEBREW_PREFIX}/opt/node@16/bin"

[[ -d "${coreutils_path}" && ":${PATH}:" != *":${coreutils_path}:"* ]] \
&& export PATH="${coreutils_path}:${PATH}"
[[ -d "${findutils_path}" && ":${PATH}:" != *":${findutils_path}:"* ]] \
&& export PATH="${findutils_path}:${PATH}"
[[ -d "${brew_path}" && ":${PATH}:" != *":${brew_path}:"* ]] \
&& export PATH="${brew_path}:${PATH}"
[[ -d "${grep_path}" && ":${PATH}:" != *":${grep_path}:"* ]] \
&& export PATH="${grep_path}:${PATH}"
[[ -d "${rust_path}" && ":${PATH}:" != *":${rust_path}:"* ]] \
&& export PATH="${rust_path}:${PATH}"
[[ -d "${node_path}" && ":${PATH}:" != *":${node_path}:"* ]] \
&& export PATH="${node_path}:${PATH}"

unset rust_path brew_path grep_path findutils_path coreutils_path node_path

################################################################################
# other exports
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

if [[ -x "$(command -v nvim)" ]]; then
  export EDITOR='nvim'
  export SUDO_EDITOR='nvim'
elif [[ -x "$(command -v vim)" ]]; then
  export EDITOR='vim'
  export SUDO_EDITOR='vim'
else
  export EDITOR='vi'
  export SUDO_EDITOR='vi'
fi

################################################################################
# aliases
################################################################################

alias ..='cd ..'
alias brewup='brew update; brew upgrade; brew upgrade --cask; brew cleanup'
alias df='df -h'
alias du='du -hd 1'
alias dust='dust -d 1'
alias grep='grep -i --color=auto'
alias less='less -FR'
alias ls='ls -Fh --color=auto --group-directories-first'
alias la='ls -A'
alias ll='ls -lA'
alias path='echo -e "${PATH//:/\\n}"'
alias pgrep='pgrep -fail'
alias ps='ps -ef'
alias rg='rg -S'
alias sudo='sudo '
if [[ -x "$(command -v nvim)" ]]; then
  alias vim='nvim'
  alias v='nvim'
fi
