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

# Alias for Homebrew Update
alias brew-latest="brew update && brew upgrade && brew cleanup && sh ~/shimech.sh"

# COM
alias ls-com="ls -l /dev/tty.*"

# composer
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.composer/vendor/bin:$PATH

# pyenv
eval "$(pyenv init -)"

# poetry
export PATH=$HOME/.local/bin:$PATH

# rbenv
[[ -d ~/.rbenv  ]] && \
  export PATH=${HOME}/.rbenv/bin:${PATH} && \
  eval "$(rbenv init -)"

# goenv
export GOENV_ROOT=$HOME/.goenv
export PATH=$GOENV_ROOT/bin:$PATH
eval "$(goenv init -)"
alias go=~/.goenv/shims/go

export PATH=$GOROOT/bin:$PATH
export PATH=$PATH:$GOPATH/bin

# anyenv
eval "$(anyenv init -)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/shuntaro/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/shuntaro/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/shuntaro/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/shuntaro/google-cloud-sdk/completion.zsh.inc'; fi

# bun completions
[ -s "/Users/shuntaro/.bun/_bun" ] && source "/Users/shuntaro/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

