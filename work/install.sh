#!/usr/bin/env bash

# check internet connection
ping -q -W 5 -c 1 8.8.8.8 > /dev/null || exit 1

########################################
# homebrew
########################################

# install homebrew if not installed
if [[ ! -x "$(command -v brew)" ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  brew update
fi

# exit 1 if installation failed
if [[ ! -x "$(command -v brew)" ]]; then
  printf "%s\\n" "Homebrew Installation failed" "Exiting..."
  exit 1
fi

formulae=(
  "composer"
  "git"
  "node"
)

# install formulae separately in case one fails
for i in "${!formulae[@]}"
do
  brew install "${formulae[i]}"
done
unset i
unset formulae

########################################
# homebrew-cask
########################################

# tap homebrew-cask
brew tap homebrew/cask

casks=(
  "atom"
  "firefox"
  "github"
  "google-chrome"
  "mamp"
  "tower"
  "slack"
)

# install casks separately in case one fails
for i in "${!casks[@]}"
do
  brew install "${casks[i]}"
done
unset i
unset casks

########################################
# npm
########################################

node_packages=(
  "grunt-cli"
  "sass"
)

# install npm packages separately in case one fails
for i in "${!node_packages[@]}"
do
  brew install "${node_packages[i]}"
done
unset i
unset node_packages

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
)
printf "%s\\n" "${input_options[@]}"
unset input_options
echo "Enter additional packages to be installed, separated by commas"

# split input by comma and whitespace into options array
echo -n "e.g. \"3, 6, 7\" default none (0):"
IFS=", " read -ra options

none_selected=false

# loop through options array and add selected options to arrays
for i in "${!options[@]}"
do
  if [[ "0" == "${options[$i]}" ]]; then
    none_selected=true
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
  fi
done
unset i
unset options

# install selected options separately in case one fails
if ! $none_selected; then
  for i in "${!formulae_options[@]}"
  do
    brew install "${formulae_options[$i]}"
  done
  unset i
  for i in "${!cask_options[@]}"
  do
    brew cask install "${cask_options[@]}"
  done
  unset i
else
  echo "No additional packages selected."
fi
unset none_selected

brew cask cleanup

echo "Done."
