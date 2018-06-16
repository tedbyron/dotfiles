#!/usr/bin/env bash

# terminate on first nonzero exit code
set -e

# check internet connection
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
  composer
  git
  node
)

# install formulae
brew install "${formulae[@]}"

########################################
# homebrew-cask
########################################

# install homebrew-cask
brew tap homebrew/cask

# homebrew casks
casks=(
  atom
  firefox
  github
  google-chrome
  mamp
  tower
  slack
)

# install casks
brew cask install "${casks[@]}"

########################################
# npm
########################################

# npm packages
npm_packages=(
  grunt-cli
  sass
)

# install npm packages
npm install -g "${npm_packages[@]}"

########################################
# optional packages
########################################

# TODO

########################################
# other
########################################

# check if bash profile or shell profile exist and add Composer alias
if [[ -a "$HOME/.bash_profile" ]]; then
  echo "alias composer=\"php /user/local/bin/composer.phar\"" >> "$HOME/.bash_profile"
elif [[ -a "$HOME/.profile" ]]; then
  echo "alias composer=\"php /user/local/bin/composer.phar\"" >> "$HOME/.profile"
else
  touch "$HOME/.bash_profile"
  echo "alias composer=\"php /user/local/bin/composer.phar\"" >> "$HOME/.bash_profile"
fi
