# shellcheck disable=SC2148,SC1091

################################################################################
# source .profile and .bashrc
################################################################################

[[ -f "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"
[[ -f "${HOME}/.profile" ]] && source "${HOME}/.profile"
