# shellcheck disable=SC2148,SC1091

# return if not running interactively
[[ -z "${PS1}" ]] && return

################################################################################
# prompt string
################################################################################

__prompt_command() {
  local -r e_status="$?"
  local c_err
  local -r c_red='\[\033[31m\]'
  local -r c_gre='\[\033[32m\]'
  local -r c_yel='\[\033[33m\]'
  local -r c_blu='\[\033[34m\]'
  local -r c_mag='\[\033[35m\]'
  local -r nc='\[\033[0m\]'
  PS1=''

  # print exit status when previous command errors
  if ((e_status == 0)); then
    c_err="${c_gre}"
    PS1+="${c_err}┌${nc} "
  else
    c_err="${c_red}"
    PS1+="${c_err}× ${e_status}\n┌${nc} "
  fi

  # time, username, hostname, working dir
  PS1+="\@ ["
  if ((EUID == 0)); then
    PS1+="${c_red}\u${nc}"
  else
    PS1+="${c_yel}\u${nc}"
  fi
  PS1+="@${c_yel}\h${nc}] \w\n"

  # check if in git work tree
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    local branch commit status c_git
    # branch name or HEAD if detached
    branch="$(git rev-parse --abbrev-ref --symbolic-full-name HEAD)"
    # tag or short commit hash
    commit="$(git name-rev --name-only --tags --no-undefined HEAD 2>/dev/null \
    || git rev-parse --short HEAD)"
    # git status
    status="$(git status --porcelain)"
    # branch or HEAD color
    c_git="${c_blu}"

    PS1+="${c_err}│${nc} ["

    # change color to c_mag if HEAD is detached
    if [[ "${branch}" == "HEAD" ]]; then
      c_git="${c_mag}"
    fi
    PS1+="${c_git}${branch}${nc}@${c_git}${commit} "

    # work tree clean or get change counts
    if [[ -z "${status}" ]]; then
      PS1+="${c_gre}●${nc}]"
    else
      # loop through $status and increment change counts
      # https://git-scm.com/docs/git-status#_short_format
      while IFS=$'\n' read -r line; do
        case "${line::2}" in
          " [AMD]") ;; # not updated
          "M[ MD]") ;; # updated in index
          "A[ MD]") ;; # added to index
          "D ") ;; # deleted from index
          "R[ MD]") ;; # renamed in index
          "C[ MD]") ;; # copied in index
          "[MARC] ") ;; # index and work tree matches
          "[ MARC]M") ;; # work tree changed since index
          "[ MARC]D") ;; # deleted in work tree
          "[ D]R") ;; # renamed in work tree
          "[ D]C") ;; # copied in work tree
          'UU' | 'AA' | 'DU' | 'UA' | 'UD' | 'AU' | 'DD') ;; # unmerged
          '??') ;; # untracked
          '!!') ;; # ignored
        esac
      done <<< "${status}"

      PS1+="${c_red}●${nc}]"
    fi

    PS1+='\n'
  fi

  PS1+="${c_err}└${nc} "

  # change prompt if root user (\$ doesn't work here?)
  if ((EUID == 0)); then
    PS1+="${c_red}#${nc} "
  else
    PS1+='$ '
  fi
}

PROMPT_COMMAND=__prompt_command

################################################################################
# path additions
################################################################################

coreutils_path='/opt/homebrew/opt/coreutils/libexec/gnubin'
findutils_path='/opt/homebrew/opt/findutils/libexec/gnubin'
grep_path='/opt/homebrew/opt/grep/libexec/gnubin'
brew_path='/opt/homebrew/sbin'
rust_path="${HOME}/.cargo/bin"
node_path="/opt/homebrew/opt/node@16/bin"

# add paths to $PATH if they exist and aren't in $PATH already
[[ -d "${coreutils_path}" && ":${PATH}:" != *":${coreutils_path}:"* ]] \
&& export PATH="${coreutils_path}:${PATH}"

[[ -d "${findutils_path}" && ":${PATH}:" != *":${findutils_path}:"* ]] \
&& export PATH="${findutils_path}:${PATH}"

[[ -d "${brew_path}" && ":${PATH}:" != *":${brew_path}:"* ]] \
&& export PATH="${brew_path}:${PATH}"

[[ -d "${grep_path}" && ":${PATH}:" != *":${grep_path}:"* ]] \
&& export PATH="${grep_path}:${PATH}"

[[ -d "${rust_path}" && ":${PATH}:" != *":${rust_path}:"* ]] \
&& export PATH="${rust_path}:${PATH}"

[[ -d "${node_path}" && ":${PATH}:" != *":${node_path}:"* ]] \
&& export PATH="${node_path}:${PATH}"

# don't source these variables
unset rust_path brew_path grep_path findutils_path coreutils_path node_path

################################################################################
# other exports
################################################################################

export LDFLAGS="-L/opt/homebrew/opt/node@16/lib"
export CPPFLAGS="-I/opt/homebrew/opt/node@16/include"

export HOMEBREW_NO_ANALYTICS=1

export BAT_THEME='Dracula'

GPG_TTY="$(tty)"
export GPG_TTY

export LESS_TERMCAP_mb=$'\033[1;31m'     # begin blink
export LESS_TERMCAP_md=$'\033[1;36m'     # begin bold
export LESS_TERMCAP_me=$'\033[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\033[1;44;33m'  # begin reverse video
export LESS_TERMCAP_se=$'\033[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\033[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\033[0m'        # reset underline

if [[ -x "$(command -v nvim)" ]]; then
  export EDITOR=nvim
  export SUDO_EDITOR=nvim
elif [[ -x "$(command -v vim)" ]]; then
  export EDITOR=vim
  export SUDO_EDITOR=vim
else
  export EDITOR=vi
  export SUDO_EDITOR=vi
fi

################################################################################
# aliases
################################################################################

# cd to parent directory
alias ..='cd ..'
# do everything except autoremove (orphaned dependencies)
alias brewup='brew update; brew upgrade; brew upgrade --cask; brew cleanup'
# human-readable
alias df='df -h'
# human-readable, max depth 1
alias du='du -hd 1'
# max depth 1
alias dust='dust -d 1'
# case insensitive, color
alias grep='grep -i --color=auto'
# quit if one screen, raw control chars
alias less='less -FR'
# classify entries, human-readable, color, directories first
alias ls='ls -Fh --color=auto --group-directories-first'
# almost all
alias la='ls -A'
# long list, almost all
alias ll='ls -lA'
# pretty print $PATH
alias path='echo -e "${PATH//:/\\n}"'
# full match, include ancestors, ignore case, long output
alias pgrep='pgrep -fail'
# all processes, full format
alias ps='ps -ef'
# smart letter case
alias rg='rg -S'
# expand aliases used with sudo
alias sudo='sudo '
# nvim if exists
if [[ -x "$(command -v nvim)" ]]; then
  alias vim='nvim'
fi
