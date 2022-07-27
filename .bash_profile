# shellcheck disable=SC2148,SC1091

eval "$(/opt/homebrew/bin/brew shellenv)"

[[ -r "${HOME}/.bashrc" ]] && source "${HOME}/.bashrc"

[[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]] \
&& source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
