# shellcheck disable=SC2148,SC1091

################################################################################
# source .profile and .bashrc
################################################################################

# homebrew
eval "$("${HOMEBREW_PREFIX}"/bin/brew shellenv)"

[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"
[[ -f "${HOME}/.profile" ]] && source "${HOME}/.profile"

# bash completion
[[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] \
&& source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
