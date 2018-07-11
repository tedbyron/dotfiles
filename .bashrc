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

# TODO: remove literal colors from PS1

# ps1
PS1="\`[[ \$? -eq 0 ]] && echo '\[\e[32m\]' || { echo '\[\e[31m\]' && exit 1; }\`┌ \[\e[39m\]\A [\[\e[33m\]\u\[\e[39m\]@\[\e[33m\]\H\[\e[39m\]] \w \n\`[[ \$? -eq 0 ]] && echo '\[\e[32m\]' || echo '\[\e[31m\]'\`└ \`[[ \$(git rev-parse --is-inside-work-tree 2>/dev/null) == 'true' ]] && { [[ \$(git status -s) ]] && echo -n '\[\e[33m\]' || echo -n '\[\e[32m\]'; } && printf '%s ' \$(git rev-parse --abbrev-ref HEAD)\`\`[[ \$(command id -u) -ne 0 ]] && echo '\[\e[39m\]' || echo '\[\e[31m\]'\`\\$ \[$(tput sgr0)\]"

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

# colorscheme
(cat ~/.cache/wal/sequences &)
