# add ~/bin to path
[[ -d "$HOME/bin" && -z "$(echo $PATH | grep -o $HOME/bin)" ]] && export PATH="$PATH:$HOME/bin"

# start ssh-agent
! pgrep -u "$USER" ssh-agent > /dev/null && ssh-agent > "$XDG_RUNTIME_DIR/ssh-agent.env"
[[ ! "$SSH_AUTH_SOCK" ]] && eval "$(<"$XDG_RUNTIME_DIR/ssh-agent.env")"

# exports
export EDITOR=vim
export PAGER="less -R"
export SUDO_EDITOR=vim
export LC_COLLATE=C
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
export LESS=-R
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

PS1="\`[[ \$? -eq 0 ]] && echo '\[\e[32m\]' || { echo '\[\e[31m\]' && exit 1; }\`┌ " # exit status
PS1+="\[\e[39m\]\A [\[\e[33m\]\u\[\e[39m\]@\[\e[33m\]\H\[\e[39m\]] \w\n" # user, host, working dir
PS1+="\`[[ \$? -eq 0 ]] && echo '\[\e[32m\]' || echo '\[\e[31m\]'\`└ " # exit status
PS1+="\`[[ \$(git rev-parse --is-inside-work-tree 2>/dev/null) == 'true' ]] && { [[ \$(git status -s) ]] && echo -n '\[\e[33m\]' || echo -n '\[\e[32m\]'; } && printf '%s ' \$(git rev-parse --abbrev-ref HEAD)\`" # git status and branch
PS1+="\`[[ $(id -u) -ne 0 ]] && echo '\[\e[39m\]' || echo '\[\e[31m\]'\`\\$ \[$(tput sgr0)\]" # user

# aliases
alias sudo="sudo "

alias dmesg="dmesg --color=always | less"
alias bootlog="journalctl -p 3 -xb"
alias syslog="systemctl --state=failed"

alias path="echo -e ${PATH//:/\\\\n}"

alias ping="prettyping --nolegend"

alias df="df -h"
alias free="free -h"

alias ls="ls -Fh --color=auto --group-directories-first"
alias ll="ls -l"
alias la="ls -A"
alias lla="ls -lA"

alias grep="grep -i --color=auto"
alias pgrep="pgrep -ai"
alias diff="diff --color=auto"

alias trash="gio trash"
alias neofetch="clear;neofetch --cpu_brand off --uptime_shorthand on --gpu_brand off --gtk_shorthand on --music_player spotify"
alias com.github.babluboy.bookworm="bookworm"

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

bookworm() {
  command "/usr/bin/com.github.babluboy.bookworm" "$@" &
}

# miscellaneous
setxkbmap -option compose:ralt

[[ $- != *i* ]] && return

(cat ~/.cache/wal/sequences &)
