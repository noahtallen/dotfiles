#!/usr/bin/env bash

# TODO:
# - Install Brew
# - Mac settings
# - Brew stuff
# - GPG
# - SSH
# - git
# - Cascadia Code NF

# Oh my zsh stuff:
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
git clone https://github.com/fdellwing/zsh-bat.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-bat
git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

stow config --target="$HOME"
stow shell --target="$HOME"
