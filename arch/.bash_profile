[[ -f ~/.bashrc ]] && source ~/.bashrc

[[ ! $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx
