#!/bin/sh

# Homebrew
echo "🍺 Upgrade Homebrew packages..."
brew update
brew upgrade
brew cleanup

# mise
echo "💻 Upgrade mise packages..."
mise upgrade

# k1y0mar0
./k1y0mar0.sh
