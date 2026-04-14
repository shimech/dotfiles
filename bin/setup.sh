#!/bin/sh

WORKDIR=$(pwd)

# Install Homebrew packages
echo "🍺 Installing Homebrew packages..."

brew bundle --file=$WORKDIR/Brewfile


# Symlink
echo "🔗 Symlinking dotfiles..."

## zsh
ln -sf $WORKDIR/.zshrc $HOME/.zshrc
ln -sf $WORKDIR/.zprofile $HOME/.zprofile
ln -sf $WORKDIR/.zshenv $HOME/.zshenv
ln -sf $WORKDIR/.zlogin $HOME/.zlogin
ln -sf $WORKDIR/.zlogout $HOME/.zlogout
ln -sf $WORKDIR/.zpreztorc $HOME/.zpreztorc

## tmux
ln -sf $WORKDIR/.tmux.conf $HOME/.tmux.conf

## Vim
ln -sf $WORKDIR/.vimrc $HOME/.vimrc
find $WORKDIR/.vim -type f | while read src; do
  dst=$HOME/.vim${src#$WORKDIR/.vim}
  mkdir -p $(dirname $dst)
  ln -sf $src $dst
done

## Neovim
mkdir -p $HOME/.config/nvim
find $WORKDIR/.config/nvim -type f | while read src; do
  dst=$HOME/.config/nvim${src#$WORKDIR/.config/nvim}
  mkdir -p $(dirname $dst)
  ln -sf $src $dst
done

## tmuxinator
mkdir -p $HOME/.config/tmuxinator
find $WORKDIR/.config/tmuxinator -type f | while read src; do
  dst=$HOME/.config/tmuxinator${src#$WORKDIR/.config/tmuxinator}
  mkdir -p $(dirname $dst)
  ln -sf $src $dst
done

## git
mkdir -p $HOME/.config/git
find $WORKDIR/.config/git -type f | while read src; do
  dst=$HOME/.config/git${src#$WORKDIR/.config/git}
  mkdir -p $(dirname $dst)
  ln -sf $src $dst
done

## Claude Code
ln -sf $WORKDIR/.claude/settings.json $HOME/.claude/settings.json
mkdir -p $HOME/.claude/hooks
for f in $WORKDIR/.claude/hooks/*; do
  ln -sf $f $HOME/.claude/hooks/
done

## Other
ln -sf $WORKDIR/latest.sh $HOME/latest.sh
ln -sf $WORKDIR/k1y0mar0.sh $HOME/k1y0mar0.sh


# Complete
figlet -f slant "Setup Completed!" | lolcat
