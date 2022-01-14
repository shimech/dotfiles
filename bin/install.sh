#!/bin/sh

WORKDIR=~/work/dotfiles

# zsh
ln -sf $WORKDIR/.zshrc ~/.zshrc
ln -sf $WORKDIR/.zprofile ~/.zprofile
ln -sf $WORKDIR/.zshenv ~/.zshenv
ln -sf $WORKDIR/.zlogin ~/.zlogin
ln -sf $WORKDIR/.zlogout ~/.zlogout
ln -sf $WORKDIR/.zpreztorc ~/.zpreztorc

# vim
ln -sf $WORKDIR/.vim ~/.vim
ln -sf $WORKDIR/.vimrc ~/.vimrc
