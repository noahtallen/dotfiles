#!/usr/bin/env bash

# TODO:
# - Install Brew
# - Mac settings
# - Brew stuff
# - Cascadia Code NF

if ! [-x command -v brew 2>&1 >/dev/null] ; then
    echo "Installing brew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Add configurations:
stow config --target="$HOME"
stow shell --target="$HOME"
stow git --target="$HOME"
stow ssh --target="$HOME"
stow fonts --target="$HOME"

# OMZ:
if ! [ -d ~/.oh-my-zsh ]; then
  echo "Installing Oh My ZSH.."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
  # And plugins!
  git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat
  git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab
fi
