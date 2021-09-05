# shellcheck disable=SC2148,SC1091

# return if not running interactively
[[ -z "${PS1}" ]] && return

# bash completion
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] \
&& source "/usr/local/etc/profile.d/bash_completion.sh"

################################################################################
# prompt string
################################################################################

prompt_command() {
  local -r e_status="$?"
  local e_color
  local -r red='\[\033[31m\]'
  local -r green='\[\033[32m\]'
  local -r yellow='\[\033[33m\]'
  local -r nc='\[\033[0m\]'
  PS1=''

  # print exit status when previous command errors
  if (( e_status == 0 )); then
    e_color="${green}"
    PS1+="${e_color}┌${nc} "
  else
    e_color="${red}"
    PS1+="${e_color}× ${e_status}\n┌${nc} "
  fi

  # time, username, hostname, working dir
  PS1+="\@ [${yellow}\u${nc}@${yellow}\h${nc}] \w\n"
  PS1+="${e_color}└${nc} "

  # change prompt if root user
  if [[ "$(id -u)" -eq 0 ]]; then
    PS1+="${red}\$${nc} "
  else
    PS1+='\$ '
  fi
}

PROMPT_COMMAND=prompt_command

################################################################################
# path additions
################################################################################

rust_path="${HOME}/.cargo/bin"
brew_path="/usr/local/sbin"
grep_path="/usr/local/opt/grep/libexec/gnubin"
findutils_path="/usr/local/opt/findutils/libexec/gnubin"
coreutils_path="/usr/local/opt/coreutils/libexec/gnubin"

# add paths to $PATH if they exist and aren't in $PATH already
[[ -d "${rust_path}" && ":${PATH}:" != *":${rust_path}:"* ]] \
&& export PATH="${rust_path}:${PATH}"
[[ -d "${brew_path}" && ":${PATH}:" != *":${brew_path}:"* ]] \
&& export PATH="${brew_path}:${PATH}"
[[ -d "${grep_path}" && ":${PATH}:" != *":${grep_path}:"* ]] \
&& export PATH="${grep_path}:${PATH}"
[[ -d "${findutils_path}" && ":${PATH}:" != *":${findutils_path}:"* ]] \
&& export PATH="${findutils_path}:${PATH}"
[[ -d "${coreutils_path}" && ":${PATH}:" != *":${coreutils_path}:"* ]] \
&& export PATH="${coreutils_path}:${PATH}"

# don't source these variables
unset rust_path brew_path grep_path findutils_path coreutils_path

################################################################################
# other exports
################################################################################

export BAT_THEME=Dracula
GPG_TTY="$(tty)"
export GPG_TTY
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

if [[ -x "$(command -v vim)" ]]; then
  export EDITOR=vim
  export SUDO_EDITOR=vim
else
  export EDITOR=vi
  export SUDO_EDITOR=vi
fi

################################################################################
# aliases
################################################################################

# cd: change to parent directory
alias ..='cd ..'
# bat: force decorations and color
alias bat='bat -f'
# brew: do everything
alias brewup='brew update; brew upgrade; brew upgrade --cask; brew cleanup'
# df: SI units
alias df='df -H'
# du: SI units, max depth 1
alias du='du -Hd 1'
# dust: max depth 1
alias dust='dust -d 1'
# grep: case insensitive, color
alias grep='grep -i --color=auto'
# less: quit if one screen, raw control chars
alias less='less -FR'
# ls: classify entries, SI units, color, directories first
alias ls='ls -F --si --color=auto --group-directories-first'
# ls: almost all
alias la='ls -A'
# ls: long list
alias ll='ls -l'
# ls: long list, almost all
alias lla='ls -lA'
# echo: pretty print $PATH
alias path='echo -e ${PATH//:/\\n}'
# pgrep: full match, include ancestors, ignore case, long output
alias pgrep='pgrep -fail'
# ps: all processes, full format
alias ps='ps -ef'
# rg: smart letter case, follow symbolic links
alias rg='rg -sL'
# sudo: expand aliases used with sudo
alias sudo='sudo '
