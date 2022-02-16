#!/usr/bin/env bash
# Doom Emacs install script for macOS.

brew tap d12frosted/emacs-plus
brew install d12frosted/emacs-plus/emacs-plus@28 \
    --with-native-comp \
    --with-xwidgets \
    --with-modern-doom-icon
ln -sf /usr/local/opt/emacs-plus@28/Emacs.app /Applications
brew services restart d12frosted/emacs-plus/emacs-plus@28

git clone https://github.com/hlissner/doom-emacs ~/.config/emacs \
    --depth 1 \
    --single-branch
~/.config/emacs/bin/doom install
