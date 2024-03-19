export ZDOTDIR=$HOME/.config/zsh

if (( $+__SESS_VARS_SOURCED )) return
export __SESS_VARS_SOURCED=1

export EDITOR=nvim
export ERL_AFLAGS='+pc unicode -kernel shell_history enabled'
export FZF_ALT_C_COMMAND='fd -HL -E .git -c always -t d --strip-cwd-prefix'
export FZF_CTRL_R_OPTS='--layout reverse'
export FZF_CTRL_T_COMMAND='fd -H -E .git -c always -t f --strip-cwd-prefix'
export FZF_CTRL_T_OPTS='--preview "bat --color always --style changes,numbers {}" --bind "ctrl-/:change-preview-window(down|hidden|)"'
export FZF_DEFAULT_COMMAND='fd -H -E .git -c always -t f --strip-cwd-prefix'
export FZF_DEFAULT_OPTS='--ansi --info inline-right --no-scrollbar --no-separator --color bg:-1,bg+:-1,fg:-1,fg+:-1,hl:#50FA7B,hl+:#FFB86C,info:#BD93F9,marker:#FF79C6,pointer:#FF79C6,prompt:#50FA7B,spinner:#FF79C6'
export GNUPGHOME=$HOME/.gnupg
export IEX_HOME=$HOME/.config/iex
export LESS=-FRi
export LESSHISTFILE=-
export MANPAGER='zsh -c "col -bx | bat -p -l man"'
export MANROFFOPT=-c
export NULLCMD=:
export PAGER=less
export READNULLCMD=bat
export RIPGREP_CONFIG_PATH=$HOME/.config/ripgrep/ripgreprc
export STARSHIP_LOG=error
export ZSH_TMUX_AUTOSTART=true
export ZSH_TMUX_CONFIG=$HOME/.config/tmux/tmux.conf

if [[ "$(uname)" == 'Darwin'* ]] {
    export __DARWIN=1
    export HOMEBREW_NO_ANALYTICS=1
}
