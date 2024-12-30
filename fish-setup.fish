#!/usr/bin/env fish

# Set default shell:
if ! cat /etc/shells | grep fish
    echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
end

# Add plugin manager:
if ! type -q fisher
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
end

# Add plugins
fisher install jorgebucaran/nvm.fish
fisher install patrickf1/fzf.fish
fisher install kidonng/zoxide.fish
fisher install ilancosman/tide

# Tide Prompt configuration
tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Few icons' --transient=No
set -U tide_character_icon '$'
set -U tide_prompt_add_newline_before true
set -U tide_right_prompt_items status\x1ecmd_duration\x1econtext\x1ejobs\x1edirenv\x1epython\x1erustc\x1ejava\x1ephp\x1epulumi\x1eruby\x1ego\x1egcloud\x1ekubectl\x1edistrobox\x1etoolbox\x1eterraform\x1enix_shell\x1ecrystal\x1eelixir\x1ezig\x1etime
