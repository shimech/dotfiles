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

# added by Anaconda2 5.2.0 installer↲
# export PATH="/Users/shuntaro/anaconda2/bin:$PATH"↲

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
eval "$(pyenv init -)"
export LDFLAGS="-L/usr/local/opt/zlib/lib -L/usr/local/opt/bzip2/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/bzip2/include"

# cdls
alias ls='ls -aG'
cdls ()
{
    \cd "$@" && ls
}
alias cd='cdls'

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
export PATH="$HOME/.poetry/bin:$PATH"i

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
