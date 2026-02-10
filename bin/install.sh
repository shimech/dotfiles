#!/bin/sh

WORKDIR=$(pwd)

# zsh
ln -sf $WORKDIR/.zshrc $HOME/.zshrc
ln -sf $WORKDIR/.zprofile $HOME/.zprofile
ln -sf $WORKDIR/.zshenv $HOME/.zshenv
ln -sf $WORKDIR/.zlogin $HOME/.zlogin
ln -sf $WORKDIR/.zlogout $HOME/.zlogout
ln -sf $WORKDIR/.zpreztorc $HOME/.zpreztorc

# Vim
ln -sf $WORKDIR/.vimrc $HOME/.vimrc
find $WORKDIR/.vim -type f | while read src; do
  dst=$HOME/.vim${src#$WORKDIR/.vim}
  mkdir -p $(dirname $dst)
  ln -sf $src $dst
done

# WezTerm
mkdir -p $HOME/.config/wezterm
for f in $WORKDIR/.config/wezterm/*; do
  ln -sf $f $HOME/.config/wezterm/
done
