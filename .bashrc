# PATH
findutils_path="/usr/local/opt/findutils/libexec/gnubin"
coreutils_path="/usr/local/opt/coreutils/libexec/gnubin"
grep_path="/usr/local/opt/grep/libexec/gnubin"
brew_path="/usr/local/sbin"

[[ -d $findutils_path && ":$PATH:" != *":$findutils_path:"* ]] && export PATH="$findutils_path:$PATH"
[[ -d $coreutils_path && ":$PATH:" != *":$coreutils_path:"* ]] && export PATH="$coreutils_path:$PATH"
[[ -d $grep_path && ":$PATH:" != *":$grep_path:"* ]] && export PATH="$grep_path:$PATH"
[[ -d $brew_path && ":$PATH:" != *":$brew_path:"* ]] && export PATH="$brew_path:$PATH"

# miscellaneous exports
export LC_COLLATE=C
export EDITOR=vim
export SUDO_EDITOR=vim
export PAGER="less -R"
export GPG_TTY=$(tty)
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

PS1="\`[[ \$? -eq 0 ]] && echo '\[\e[32m\]' || { echo '\[\e[31m\]' && exit 1; }\`┌ " # exit status
PS1+="\[\e[39m\]\@ [\[\e[33m\]\u\[\e[39m\]@\[\e[33m\]\h\[\e[39m\]] \w\n" # user, host, working dir
PS1+="\`[[ \$? -eq 0 ]] && echo '\[\e[32m\]' || echo '\[\e[31m\]'\`└ " # exit status
PS1+="\`[[ $(id -u) -ne 0 ]] && echo '\[\e[39m\]' || echo '\[\e[31m\]'\`\\$ \[$(tput sgr0)\]" # root indicator

# aliases
alias brewup="brew update && brew upgrade && brew cleanup"
alias df="df -h"
alias diff="diff --color=auto"
alias free="free -h"
alias grep="grep -i --color=auto"
alias ls="ls -Fh --color=auto --group-directories-first"
alias la="ls -A"
alias ll="ls -l"
alias lla="ls -lA"
alias path="echo -e ${PATH//:/\\\\n}"
alias pip="pip3"
alias pgrep="pgrep -ail"
alias ps="ps ax"
alias psg="ps | grep -v grep | grep $@"
alias sudo="sudo "

# overloads
man() {
  LESS_TERMCAP_mb=$(printf "\e[1;32m") \
  LESS_TERMCAP_md=$(printf "\e[1;32m") \
  LESS_TERMCAP_me=$(printf "\e[0m") \
  LESS_TERMCAP_se=$(printf "\e[0m") \
  LESS_TERMCAP_us=$(printf "\e[1;34m") \
  LESS_TERMCAP_ue=$(printf "\e[0m") \
  command man "$@"
}

du() {
  command du -hd 1 "$@" 2> >(grep -v 'Permission denied') | command sort -fk 2
}

[[ $- != *i* ]] && return
