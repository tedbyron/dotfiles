zstyle ':znap:*' repos-dir ~/.local/share/zsh-snap
source ~/.local/share/zsh-snap/znap.zsh
[[ "$TERM_PROGRAM" == "iTerm.app" ]] \
  && znap eval iterm2 'curl -fsSL https://iterm2.com/shell_integration/zsh'
znap eval brew '/opt/homebrew/bin/brew shellenv'
znap eval starship 'starship init zsh --print-full-init'
znap prompt

# plugins

znap source ohmyzsh/ohmyzsh \
  lib/{completion,correction,directories,history} \
  plugins/git
znap source zsh-users/zsh-autosuggestions
znap source zsh-users/zsh-completions
znap source zsh-users/zsh-history-substring-search
# must be last: https://github.com/zsh-users/zsh-syntax-highlighting#faq
znap source zsh-users/zsh-syntax-highlighting

# zsh

setopt auto_cd
setopt interactive_comments
setopt long_list_jobs
setopt multios
setopt no_beep

bindkey -e
bindkey '^ ' autosuggest-accept

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down
export HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# path

path=(
  "${HOMEBREW_PREFIX}/sbin"
  "${HOMEBREW_PREFIX}/opt/coreutils/libexec/gnubin"
  "${HOMEBREW_PREFIX}/opt/findutils/libexec/gnubin"
  "${HOMEBREW_PREFIX}/opt/grep/libexec/gnubin"
  "${HOME}/.cargo/bin"
  $path
)

# functions

znap fpath _rustup 'rustup completions zsh'
znap fpath _cargo 'rustup completions zsh cargo'

# misc exports

export STARSHIP_LOG=error
export HOMEBREW_NO_ANALYTICS=1

GPG_TTY="$(tty)"
export GPG_TTY

export LESS_TERMCAP_mb=$'\033[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\033[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\033[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\033[1;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\033[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\033[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\033[0m'        # reset underline

export EDITOR='nvim'
export SUDO_EDITOR='nvim'

export BAT_THEME='Dracula'

export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
[[ -s "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"

export PNPM_HOME="/Users/ted/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# aliases

alias up='brew update; brew upgrade; brew upgrade --cask; brew cleanup; \
rustup update; cargo install-update -a'
alias df='df -h'
alias du='du -hd 1'
alias dust='dust -d 1'
alias grep='grep -i --color=auto'
alias less='less -FR'
alias ls='ls -Fh --color=auto --group-directories-first'
alias la='ls -A'
alias l='ls -lA'
alias path='echo -e ${PATH//:/\\n}'
alias pgrep='pgrep -fail'
alias ps='ps -ef'
alias rg='rg -S'
alias sudo='sudo '

alias y='yarn'
alias ya='yarn add'
alias yad='yarn add --dev'
alias yao='yarn add --optional'
alias yap='yarn add --peer'
alias yb='yarn build'
alias yc='yarn check'
alias ycc='yarn cache clean'
alias ycfg='yarn config'
alias ycg='yarn config get'
alias ycs='yarn config set'
alias ycu='yarn config unset'
alias yd='yarn dev'
alias ydd='yarn dedupe'
alias ye='yarn exec'
alias yep='yarn explain peer-requirements'
alias yf='yarn format'
alias yi='yarn info'
alias yin='yarn info --name-only'
alias yinit='yarn init'
alias yir='yarn info --recursive'
alias yl='yarn lint'
alias ylf='yarn lint --fix'
alias yn='yarn npm'
alias ypack='yarn pack'
alias ypli='yarn plugin import'
alias ypll='yarn plugin list'
alias yplr='yarn plugin runtime'
alias ypr='yarn preview'
alias yrb='yarn rebuild'
alias yrm='yarn remove'
alias ys='yarn search'
alias yse='yarn serve'
alias yst='yarn start'
alias yt='yarn test'
alias yui='yarn upgrade-interactive'
alias yup='yarn up'
alias yv='yarn --version'
alias yver='yarn version'
alias yw='yarn workspace'
alias ywf='yarn workspaces focus'
alias ywfe='yarn workspaces foreach'
alias ywl='yarn workspaces list'
alias yx='yarn dlx'

alias p='pnpm'
alias pa='pnpm add'
alias pad='pnpm add --save-dev'
alias pao='pnpm add --save-optional'
alias pap='pnpm add --save-peer'
alias pb='pnpm build'
alias pc='pnpm check'
alias pd='pnpm dev'
alias pf='pnpm format'
alias pi='pnpm i'
alias pinit='pnpm init'
alias pl='pnpm lint'
alias plf='pnpm lint --fix'
alias plr='pnpm ls --recursive'
alias pls='pnpm ls'
alias pout='pnpm outdated'
alias pp='pnpm prune'
alias ppack='pnpm pack'
alias ppr='pnpm preview'
alias prm='pnpm rm'
alias pse='pnpm serve'
alias psp='pnpm store prune'
alias pst='pnpm start'
alias pt='pnpm test'
alias pui='pnpm up --interactive'
alias puil='pnpm up --interactive --latest'
alias pup='pnpm up'
alias pv='pnpm --version'
alias px='pnpm dlx'
