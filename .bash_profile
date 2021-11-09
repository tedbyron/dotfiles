# shellcheck disable=SC2148,SC1091

################################################################################
# source .profile and .bashrc
################################################################################

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"
[[ -f "${HOME}/.profile" ]] && source "${HOME}/.profile"

# bash completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] \
&& source "/opt/homebrew/etc/profile.d/bash_completion.sh"
