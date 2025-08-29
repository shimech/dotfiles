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

alias latest="brew-latest && mise upgrade"

# Alias for Homebrew Update
alias brew-latest="brew update && brew upgrade && brew cleanup && sh ~/shimech.sh"

# COM
alias ls-com="ls -l /dev/tty.*"

# ripgrep
alias rg="rg --hidden"

# composer
export PATH=/usr/local/bin:$PATH
export PATH=$HOME/.composer/vendor/bin:$PATH

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/shuntaro/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/shuntaro/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/shuntaro/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/shuntaro/google-cloud-sdk/completion.zsh.inc'; fi

# mise
eval "$(~/.local/bin/mise activate zsh)"

# JDK
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-21.jdk/Contents/Home

