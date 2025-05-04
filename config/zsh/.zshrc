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
    $HOME/.local/bin
    $HOME/.cargo/bin
    $HOME/.fly/bin
    $HOME/.spicetify
)

export GPG_TTY="$(tty)"

znap source ohmyzsh/ohmyzsh \
    lib/{completion,correction,directories,history} \
    plugins/{git,tmux}
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-syntax-highlighting
znap source zsh-users/zsh-history-substring-search

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=$ZDOTDIR/.zsh_history
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

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
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_save_no_dups

znap fpath _rustup 'rustup completions zsh'
znap fpath _cargo 'rustup completions zsh cargo'

bindkey -e
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
bindkey -M menuselect '^[[Z' reverse-menu-complete
bindkey \^U backward-kill-line

alias df='df \-h'
alias dl='yt-dlp'
alias dls='dl --embed-subs --sub-lang "en.*"'
alias dlx='dl -x --audio-quality 0'
alias du='du \-h -d 1'
alias fcir='fc -IR'
alias fcl='fc -lr'
alias free='free \-h'
alias gba='git branch -avv'
alias gbl='git blame -wCCC'
alias gbr='git branch -rv'
alias gdc='git diff --check'
alias gdcas='git diff --cached --stat'
alias gds='git diff --stat'
alias gdst='git diff --staged'
alias grep='grep -Ei --color=auto'
alias gmv='git mv'
alias hf='hyperfine'
alias j='just'
alias jg='just -g'
if (( $+commands[gls] )) {
    alias ls='gls -FHh -I ".DS_Store" --color=auto --group-directories-first'
} else {
    alias ls='ls -FHh -I ".DS_Store" --color=auto --group-directories-first'
}
alias la='ls -A'
alias l='ls -Al'
alias mv='mv -i'
alias nc='ncat'
alias pgrep='pgrep -afil'
alias ps='ps -aefx'
alias sudo='sudo '
alias wlcopy='wl-copy'
alias wlpaste='wl-paste'

alias -g -- -h='-h 2>&1 | bat -p -l help'
alias -g -- --help='--help 2>&1 | bat -p -l help'

# e()     { pgrep emacs && emacsclient -n $@ || emacs -nw $@ }
# ediff() emacs -nw --eval "(ediff-files \"$1\" \"$2\")"
# eman()  emacs -nw --eval "(switch-to-buffer (man \"$1\"))"
# ekill() emacsclient --eval '(kill-emacs)'
which() echo 'Use `where`, idiot'

unalias grhh

hash -d dls=$HOME/Downloads
hash -d dot=$HOME/git/dotfiles
hash -d git=$HOME/git
if (( $+__DARWIN )) {
    hash -d pub=$HOME/Public
}
