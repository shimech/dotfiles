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

alias ls='ls -aG'
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

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
eval "$(pyenv init -)"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# PostgresSQL
export PGDATA=/usr/local/var/postgres

# Java8
export JAVA_HOME=`/usr/libexec/java_home -v "1.8"`
PATH=${JAVA_HOME}/bin:${PATH}

# Alias for Homebrew Update
alias brew-latest="brew update && brew upgrade && brew cleanup && sh ~/shimech.sh"

# Node.js
export PATH="$HOME/.nodebrew/current/bin:$PATH"

# composer
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Git
alias g="git status; git branch"
alias gn="git config user.name"
alias ge="git config user.email"

# COM
alias ls-com="ls -l /dev/tty.*"

# poetry
export PATH="$HOME/.poetry/bin:$PATH"

# rbenv
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

# goenv
export GOENV_ROOT="$HOME/.goenv"
export PATH="$GOENV_ROOT/bin:$PATH"
eval "$(goenv init -)"

# nodenv
export PATH="$HOME/.nodenv/bin:$PATH"
eval "$(nodenv init -)"
