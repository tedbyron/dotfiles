#!/usr/bin/env zsh

# check if working dir is dotfiles
if [[ ${PWD##*/} != dotfiles ]]; then
  print -P '%F{red}ERR%f: not in dotfiles directory.'
  exit 1
fi

# download stuff
print -P "%F{yellow}Installing antigen"
curl -fsSL git.io/antigen > ${HOME}/antigen.zsh
print -P "%F{yellow}Installing starship"
emulate sh -c '$(curl -fsSL https://starship.rs/install.sh)'

# link files
ln -sf ${PWD}/.zshrc ${HOME}/.zshrc
ln -sf ${PWD}/.vimrc ${HOME}/.vimrc
ln -sf ${PWD}/scripts ${HOME}/scripts

# cleanup any bash files
rm -r ${HOME:?}/bash*
