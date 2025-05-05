export ZDOTDIR=$HOME/.config/zsh

if (( $+__SESS_VARS_SOURCED )) return
export __SESS_VARS_SOURCED=1

export EDITOR=nvim
export ERL_AFLAGS='+pc unicode -kernel shell_history enabled'
export FZF_ALT_C_COMMAND='fd -HL -c always -t d --strip-cwd-prefix'
export FZF_CTRL_R_OPTS='--layout reverse'
export FZF_CTRL_T_COMMAND='fd -H -E .DS_Store -c always -t f --strip-cwd-prefix'
export FZF_CTRL_T_OPTS='--preview "bat --color always --style changes,numbers {}" --bind "ctrl-/:change-preview-window(down|hidden|)"'
export FZF_DEFAULT_COMMAND='fd -H -E .DS_Store -c always -t f --strip-cwd-prefix'
export FZF_DEFAULT_OPTS='--ansi --info inline-right --no-scrollbar --no-separator --color bg:-1,bg+:-1,fg:-1,fg+:-1,hl:#7daea3,hl+:#7daea3,info:#d8a657,marker:#89b482,pointer:#89b482,prompt:#a9b665,spinner:#89b482'
export GNUPGHOME=$HOME/.gnupg
export GOPATH=$HOME/.go
export IEX_HOME=$HOME/.config/iex
export LESS=-FRi
export LESSHISTFILE=-
export MANPAGER='zsh -c "col -bx | bat -p -l man"'
export MANROFFOPT=-c
export NODE_REPL_HISTORY=' '
export NULLCMD=:
export PAGER=less
export READNULLCMD=bat
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/ripgreprc
export STARSHIP_LOG=error
export ZSH_TMUX_CONFIG=$HOME/.config/tmux/tmux.conf

if [[ "$(uname)" == 'Darwin'* ]] {
    export __DARWIN=1
    export HOMEBREW_NO_ANALYTICS=1
    export ZSH_TMUX_AUTOSTART=true
}
