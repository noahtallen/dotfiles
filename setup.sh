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
echo -e "\nSymlinking configs..."
stow shell --target="$HOME"
stow git --target="$HOME"
stow ssh --target="$HOME"
stow gnupg --target="$HOME"
stow config --target="$HOME"

echo -e "\nInstalling fish..."
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

# macOS options, see https://macos-defaults.com/
# use "defaults delete $domain $setting" to reset values. -g uses NSGlobalDomain for $domain
# Only configure sometimes -- change the os_setting check when a new variable is added so that
# configuration runs again on machines that don't have that variable.
os_setting=$(defaults read com.apple.TimeMachine DoNotOfferNewDisksForBackup 2>/dev/null || true)
if [ "$(uname)" == "Darwin" ] && [ "$os_setting" != 1 ]; then
    echo -e "\nSetting macOS options..."
    # cmd-ctrl drag windows around:
    defaults write -g NSWindowShouldDragOnGesture -bool true

    # Show hidden files and extensions in Finder:
    defaults write com.apple.finder AppleShowAllFiles true
    defaults write com.apple.finder ShowPathbar -bool true
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    defaults write -g AppleShowAllExtensions -bool true

    # Add three-finger drag:
    defaults write com.apple.AppleMultitouchTrackpad DragLock -bool false
    defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

    # Faster animations across various things (these may no longer work):
    defaults write -g NSAutomaticWindowAnimationsEnabled -bool false
    defaults write -g QLPanelAnimationDuration -float 0.2
    defaults write -g NSWindowResizeTime -float 0.001

    # Dock animations:
    defaults write com.apple.dock autohide -bool true
    defaults write com.apple.dock autohide-delay -float 0
    defaults write com.apple.dock autohide-time-modifier -float 0.5
    defaults write com.apple.dock mineffect -string scale

    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    killall Finder
    killall Dock
fi
