#!/usr/bin/env bash

# terminate on first nonzero exit code
set -e

# check internet connection
echo "Checking for internets..."
if ping -q -c 1 -W 5 8.8.8.8 >/dev/null; then
  echo -e "No internet connection\\nExiting..."
  exit 1
fi

########################################
# homebrew-cask
########################################

# install homebrew if not installed
if [[ ! -x $(command -v brew) ]]; then
  echo "Installing Homebrew..."
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  brew update
fi

# homebrew formulae
formulae=(
  "git"
  "node"
)

# install formulae
brew install "${formulae[@]}"

########################################
# homebrew-cask
########################################

# tap homebrew-cask
brew tap homebrew/cask

# homebrew casks
casks=(
  "atom"
  "firefox"
  "github"
  "google-chrome"
  "mamp"
  "tower"
  "slack"
)

# install casks
brew cask install "${casks[@]}"

########################################
# npm
########################################

# npm packages
npm_packages=(
  "grunt-cli"
  "sass"
)

# install npm packages
npm install -g "${npm_packages[@]}"

########################################
# optional packages
########################################

# input options array to display
input_options=(
  "(0) none"
  "(1) all"
  "Homebrew"
  "   (2) emacs"
  "   (3) nano"
  "   (4) neovim"
  "   (5) vim"
  "Homebrew-Cask"
  "   (6) gpg-suite"
  "   (7) karabiner-elements"
  "   (8) spectacle"
)
printf '%s\n' "${input_options[@]}"
echo "Enter optional packages to be installed, separated by commas:"

# split input by comma and whitespace into options array
IFS=", " read -pra "e.g. \"3, 6, 7\" default none (0):" options

options_none=1

# loop through options array and add selected options to arrays
for i in "${!options[@]}"
do
  if [[ "0" == "${options[$i]}" ]]; then
    options_none=0
    break
  elif [[ "1" == "${options[$i]}" ]]; then
    formulae_options=(
      "emacs"
      "nano"
      "neovim"
      "vim"
    )
    cask_options=(
      "gpg-suite"
      "karabiner-elements"
      "spectacle"
    )
    break
  elif [[ "2" == "${options[$i]}" ]]; then
    formulae_options+=("emacs")
  elif [[ "3" == "${options[$i]}" ]]; then
    formulae_options+=("nano")
  elif [[ "4" == "${options[$i]}" ]]; then
    formulae_options+=("neovim")
  elif [[ "5" == "${options[$i]}" ]]; then
    formulae_options+=("vim")
  elif [[ "6" == "${options[$i]}" ]]; then
    cask_options+=("gpg-suite")
  elif [[ "7" == "${options[$i]}" ]]; then
    cask_options+=("karabiner-elements")
  elif [[ "8" == "${options[$i]}" ]]; then
    cask_options+=("spectacle")
  fi
done

# install selected options
if [[ options_none -eq 1 ]]; then
  brew install "${formulae_options[@]}"
  brew cask install "${cask_options[@]}"
fi

printf '\n%s\n' "Done."