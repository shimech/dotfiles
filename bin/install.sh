#!/bin/sh

WORKDIR=$(pwd)

# zsh
ln -sf $WORKDIR/.zshrc $HOME/.zshrc
ln -sf $WORKDIR/.zprofile $HOME/.zprofile
ln -sf $WORKDIR/.zshenv $HOME/.zshenv
ln -sf $WORKDIR/.zlogin $HOME/.zlogin
ln -sf $WORKDIR/.zlogout $HOME/.zlogout
ln -sf $WORKDIR/.zpreztorc $HOME/.zpreztorc

# WezTerm
for f in $WORKDIR/.config/wezterm/*; do
  ln -sf "$f" $HOME/.config/wezterm/
done
