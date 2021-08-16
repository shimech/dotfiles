#
# Executes commands at the start of an interactive session.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Source Prezto.
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# Customize to your needs...

# 自動修正
setopt correct
setopt correct_all
# cd省略
setopt auto_cd

alias ls="ls -a"
# cd + ls
function chpwd() { ls }
# mkdir + cd
function mkcd() {
  if [[ -d $1 ]]; then
    echo "It already exists! cd to the directory."
    cd $1
  else
    mkdir -p $1 && cd $1
  fi
}

# Git
alias g="git status; git branch"
alias gn="git config user.name"
alias ge="git config user.email"

# apt update & upgrade
alias apt-latest="sudo apt update && sudo apt upgrade"
