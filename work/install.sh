#!/usr/bin/env bash

# check internet connection
echo "Checking for internets..."
ping -q -W 5 -c 1 8.8.8.8 > /dev/null || exit 1

########################################
# homebrew
########################################

# install homebrew if not installed
if [[ ! -x $(command -v brew) ]]; then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  brew update
fi

# exit 1 if installation failed
if [[ ! -x $(command -v brew) ]]; then
  printf "%s\\n" "Homebrew Installation failed" "Exiting..."
  exit 1
fi

# install formulae separately in case one fails
brew install bash
brew install composer
brew install git
brew install node

# change shell to newer version of bash
chmod u+w /etc/shells
echo "/usr/local/bin/bash" > /etc/shells
chmod u-w /etc/shells
chsh -s /usr/local/bin/bash

########################################
# homebrew-cask
########################################

# tap homebrew-cask
brew tap homebrew/cask

# install casks separately in case one fails
brew cask install atom
brew cask install firefox
brew cask install github
brew cask install google-chrome
brew cask install mamp
brew cask install tower
brew cask install slack

########################################
# npm
########################################

# install npm packages separately in case one fails
npm install -g grunt-cli
npm install -g sass

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
printf "%s\\n" "${input_options[@]}"
echo "Enter additional packages to be installed, separated by commas"

# split input by comma and whitespace into options array
IFS=", " read -pra "e.g. \"3, 6, 7\" default none (0):" options

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
if ! $none_selected; then
  brew install "${formulae_options[@]}"
  brew cask install "${cask_options[@]}"
else
  echo "No additional packages selected."
fi

echo "Done."

# TODO: fix optional package install, fix bash upgrade
