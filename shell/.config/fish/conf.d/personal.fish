# Shared aliases and ENV
source "$HOME/.shared_env"

# Replace cd with zoxide:
set -U zoxide_cmd cd

# Things I did to the tide prompt:
# tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Compact --icons='Few icons' --transient=No
# set -U tide_character_icon '$'
# set -U tide_prompt_add_newline_before true
# set -U tide_right_prompt_items status\x1ecmd_duration\x1econtext\x1ejobs\x1edirenv\x1epython\x1erustc\x1ejava\x1ephp\x1epulumi\x1eruby\x1ego\x1egcloud\x1ekubectl\x1edistrobox\x1etoolbox\x1eterraform\x1enix_shell\x1ecrystal\x1eelixir\x1ezig\x1etime
