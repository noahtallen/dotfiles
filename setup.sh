#!/usr/bin/env bash
set -euo pipefail

if ! type brew > /dev/null ; then
    echo "Installing brew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew already installed."
fi

echo -e "\nChecking brew programs"
brew bundle install

# symlink configurations: (fails if there are existing files, but if you do stow --adopt, it will link with the existing contents, letting you see the differences via git.)
stow shell --target="$HOME"
stow git --target="$HOME"
stow ssh --target="$HOME"
stow gnupg --target="$HOME"
stow config --target="$HOME"

fish ./fish-setup.fish

echo -e "\nChecking OMZ..."
if ! [ -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

echo -e "\nChecking zsh plugins..."
z_plugins=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins
if ! [ -d "$z_plugins/zsh-bat" ]; then
  git clone https://github.com/fdellwing/zsh-bat.git "$z_plugins/zsh-bat"
fi
if ! [ -d "$z_plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab "$z_plugins/fzf-tab"
fi

# Add fonts -- symlinks don't work for this
echo -e "\nCopying fonts..."
cp -rf ./fonts/ ~/Library/Fonts/
