# path
[[ -d "$HOME/bin" && -z "$(echo $PATH | grep -o $HOME/bin)" ]] && export PATH="${PATH}:$HOME/bin"

if [[ -x "$(command -v npm)" && -d "$HOME/.npm-global" ]]; then
  [[ "$(npm prefix -g)" != "$HOME/.npm-global" ]] && npm config set prefix "$HOME/.npm-global"
  [[ -z "$(echo $PATH | grep -o $HOME/.npm-global)" ]] && export PATH="${PATH}:$HOME/.npm-global"
fi

# globals
export EDITOR=vim
export PAGER="less -R"
export SUDO_EDITOR=vim
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# ps1
PS1="[\u@\h \W] \\$ \[$(tput sgr0)\]"

# aliases
alias sudo="sudo " # check if commands following sudo are aliases

alias bootlog="journalctl -p 3 -xb"
alias syslog="systemctl --failed"

alias path="echo -e ${PATH//:/\\\\n}"

alias df="df -h"
alias free="free -h"

alias ls="LC_COLLATE=C ls -Fh --color=auto --group-directories-first"
alias ll="ls -l"
alias la="ls -A"
alias lla="ls -lA"

alias grep="grep -i --color=auto"
alias less="less -R"

alias trash="gio trash"
alias neofetch="clear; neofetch"
alias com.github.babluboy.bookworm="bookworm"
alias bigup="yay;npm update -g; apm update -c"

# wrapped aliases
du() {
  command du -hd 1 "$@" 2> >(grep -v 'Permission denied') | LC_COLLATE=C sort -fk 2
}

bookworm() {
  command "/usr/bin/com.github.babluboy.bookworm" "$@" &
}

mpv() {
  command mpv "$@" &
}

# set compose key
setxkbmap -option compose:ralt

# return if shell is not interactive
[[ $- != *i* ]] && return

# ps1
PS1="[\[\e[36m\]\u\[\e[m\]@\[\e[35m\]\h\[\e[m\] \[\e[33m\]\W\[\e[m\]] \\$ "

# colorscheme
(cat ~/.cache/wal/sequences &)
