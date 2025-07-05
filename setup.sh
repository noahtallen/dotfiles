#!/usr/bin/env bash
set -euo pipefail

if ! type brew > /dev/null ; then
    echo "Installing brew..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Brew already installed."
fi

echo -e "\nChecking brew programs"
brew bundle install --file ./Brewfile

if [ "$(uname)" == "Darwin" ] ; then
    brew bundle install --file ./Brewfile-maconly
fi

function stow_adopt {
    source_dir="$1"
    if ! stow config --target="$HOME" ; then
        read -p "Symlinking $1 failed, try stow with --adopt? (y/n) " -n 1 -r
        echo    # (optional) move to a new line
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            stow config --adopt --target="$HOME"
        fi
    fi
}

# symlink configurations: (fails if there are existing files, but if you do stow --adopt, it will link with the existing contents, letting you see the differences via git.)
echo -e "\nSymlinking configs..."
stow_adopt shell
stow_adopt git
stow_adopt ssh
stow_adopt gnupg
stow_adopt config

# No fish for now...
# echo -e "\nInstalling fish..."
# fish ./fish-setup.fish
if ! which chsh ; then
    # using system like universal blue which uses usermods instead:
    sudo usermod --shell /home/linuxbrew/.linuxbrew/bin/zsh ${USER}
elif [ "$SHELL" != /bin/zsh ] ; then
    chsh -s /bin/zsh
fi

echo -e "\nChecking OMZ..."
if ! [ -d ~/.oh-my-zsh ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi

echo -e "\nChecking zsh plugins..."
z_plugins=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins
z_themes=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes
if ! [ -d "$z_plugins/zsh-bat" ]; then
  git clone https://github.com/fdellwing/zsh-bat.git "$z_plugins/zsh-bat" --depth=1
fi
if ! [ -d "$z_plugins/fzf-tab" ]; then
  git clone https://github.com/Aloxaf/fzf-tab "$z_plugins/fzf-tab" --depth=1
fi
if ! [ -d "$z_plugins/terraform" ]; then
  git clone https://github.com/macunha1/zsh-terraform "$z_plugins/terraform"
fi
if ! [ -d "$z_themes/spaceship-prompt" ]; then
    git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$z_themes/spaceship-prompt" --depth=1
    ln -s "$z_themes/spaceship-prompt/spaceship.zsh-theme" "$z_themes/spaceship.zsh-theme"
fi

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

    # Add fonts -- symlinks don't work for this. Currently only for mac, in Linux we put them in blue build.
    echo -e "\nCopying fonts..."
    cp -rf ./fonts/ ~/Library/Fonts/
fi
