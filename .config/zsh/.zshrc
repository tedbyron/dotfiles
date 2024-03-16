typeset -U PATH path CDPATH cdpath FPATH fpath MANPATH manpath

zstyle ':znap:*' repos-dir ~/.local/share/zsh-snap-repos
zstyle ':znap:*:*' git-maintenance off
. ~/.local/share/zsh-snap/znap.zsh
znap eval starship 'starship init zsh --print-full-init'
znap prompt

if (( $+__DARWIN )) {
    if [[ "$(arch)" == 'arm64'* ]] {
        znap eval brew '/opt/homebrew/bin/brew shellenv'
    } else {
        znap eval brew '/usr/local/bin/brew shellenv'
    }

    if (( $+HOMEBREW_PREFIX )) {
        path=(
            $HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin
            $HOMEBREW_PREFIX/opt/findutils/libexec/gnubin
            $HOMEBREW_PREFIX/opt/grep/libexec/gnubin
            $HOMEBREW_PREFIX/opt/gnu-sed/libexec/gnubin
            $path
        )
    }
}

path+=(
    $HOME/.cargo/bin
    $HOME/.fly/bin
    $HOME/.spicetify
)

setopt always_to_end
setopt no_append_create
setopt auto_cd
setopt auto_pushd
setopt no_beep
setopt cd_silent
setopt check_jobs
setopt check_running_jobs
setopt no_clobber
setopt no_clobber_empty
setopt combining_chars
setopt complete_in_word
setopt no_flow_control
setopt long_list_jobs
setopt pushd_minus
setopt pushd_silent
setopt pushd_to_home
setopt multios
setopt typeset_silent

export GPG_TTY="$(tty)"

znap source ohmyzsh/ohmyzsh \
    lib/{completion,correction,directories,history} \
    plugins/{git,tmux}
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search

unsetopt extended_history
unsetopt hist_expire_dups_first

HISTSIZE=10000
SAVEHIST=10000
HISTORY_IGNORE="(\
> *|\
builtin *|\
kill *|\
mkdir *|\
pkill *|\
rm *|\
rmdir *|\
touch *|\
unlink *\
)"
HISTFILE=$ZDOTDIR/.zsh_history

znap fpath _rustup 'rustup completions zsh'
znap fpath _cargo 'rustup completions zsh cargo'

bindkey -e
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey -M menuselect '^[[Z' reverse-menu-complete

alias df='df \-h'
alias du='du \-h -d 1'
alias fcir='fc -IR'
alias gba='git branch -avv'
alias gbl='git blame -wCCC'
alias gbr='git branch -rv'
alias gdc='git diff --cached'
alias grhh=
alias grep='grep -Ei --color=auto'
alias gmv='git mv'
if (( $+__DARWIN )) {
    if (( $+commands[gls] )) {
        alias ls='gls -FHh -I ".DS_Store" --color=auto --group-directories-first'
    } else {
        alias ls='ls -FHh -I ".DS_Store" --color=auto --group-directories-first'
    }
} else {
    alias ls='ls -FHh --color=auto --group-directories-first'
}
alias la='ls -A'
alias l='ls -Al'
alias pgrep='pgrep -afil'
alias ps='ps -Aafx'
alias sudo='sudo '

alias -g -- -h='-h 2>&1 | bat -p -l help'
alias -g -- --help='--help 2>&1 | bat -p -l help'

hash -d dot=$HOME/git/dotfiles
hash -d git=$HOME/git
if (( $+__DARWIN )) {
    hash -d dls=$HOME/Downloads
    hash -d pub=$HOME/Public
}
