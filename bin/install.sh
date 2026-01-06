#!/bin/sh

WORKDIR=~/works/github.com/shimech/dotfiles

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

# WezTerm
ln -sf $WORKDIR/.config/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
ln -sf $WORKDIR/.config/wezterm/keybinds.lua ~/.config/wezterm/keybinds.lua
ln -sf $WORKDIR/.config/wezterm/on.lua ~/.config/wezterm/on.lua
