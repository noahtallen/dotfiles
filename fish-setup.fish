#!/usr/bin/env fish

# Set default shell:
set needs_restart false
if ! cat /etc/shells | grep -q fish
    echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
    chsh -s /opt/homebrew/bin/fish

    set needs_restart true
end

# Add plugin manager:
if ! type -q fisher
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
end

if test "$needs_restart" = true
    echo "Fish has been set as the default shell. Open a new shell (which should now be fish), and run ./setup.sh again to continue."
   exit
end

# Add plugins if not installed:
for plugin in patrickf1/fzf.fish icezyclon/zoxide.fish ilancosman/tide@v6
    if ! cat ~/.config/fish/fish_plugins | grep -q "$plugin"
        fisher install "$plugin"
    end
end

# Tide Prompt configuration
if test "$tide_character_icon" != '$'
    tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Few icons' --transient=No
end

# These can safely run any time we run the script, but the above command
# does weird things to the shell, so only do it the first time.
set -U tide_character_icon '$'
set -U tide_prompt_add_newline_before true
set -U tide_right_prompt_items status\x1ecmd_duration\x1econtext\x1ejobs\x1edirenv\x1epulumi\x1ego\x1egcloud\x1ekubectl\x1edistrobox\x1etoolbox\x1eterraform\x1enix_shell\x1ecrystal\x1etime
set -U tide_git_truncation_length 50
