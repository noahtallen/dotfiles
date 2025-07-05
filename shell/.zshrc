# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
source "$HOME/.shared_env"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"

plugins=(git zsh-bat nvm fzf-tab terraform aws)

# Lazy load nvm so it doesn't happen on every new termianl
zstyle ':omz:plugins:nvm' lazy yes

brew_dir=$(brew --prefix)

source $ZSH/oh-my-zsh.sh
fpath+="$brew_dir/share/zshc/site-functions"

# Shared aliases and path options

# fnm (faster nvm)
eval "$(fnm env --use-on-cd)"

# autocorrect commands:
eval $(thefuck --alias)

# Pure Prompt for zsh (using spaceship now)
# PURE_PROMPT_SYMBOL="$"
# autoload -U promptinit; promptinit
# zstyle :prompt:pure:git:stash show yes
# prompt pure

# Various CLI tools that need initialization & zsh integration
export FZF_DEFAULT_OPTS="--bind 'ctrl-y:execute-silent(echo -n {1..} | pbcopy)+abort'"
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'tree -C {} | head -200' ;;
    *)            fzf "$@" ;;
  esac
}

source <(fzf --zsh)
eval "$(zoxide init zsh)"
alias cd="z"
source "$brew_dir/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
