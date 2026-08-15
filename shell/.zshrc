# shard_env contains aliases, env vars, path, etc. Shared among shells.
source "$HOME/.shared_env"
brew_dir=$(brew --prefix)
eval "$(mise activate zsh)"

### zsh history settings
# https://github.com/junegunn/fzf/issues/600#issuecomment-714502300
export HISTFILE=~/.zsh_history
export HISTFILESIZE=1000000000
export HISTSIZE=1000000000
setopt INC_APPEND_HISTORY
export HISTTIMEFORMAT="[%F %T] "
setopt EXTENDED_HISTORY
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS


### zsh keybindings
bindkey -e
# Use the up and down keys to navigate the history
bindkey "\e[A" history-beginning-search-backward
bindkey "\e[B" history-beginning-search-forward

### zsh settings
setopt autocd

### fzf options
export FZF_DEFAULT_OPTS="--bind 'ctrl-y:execute-silent(echo -n {1..} | pbcopy)+abort'" # ctrl-y copies to clipboard
export FZF_CTRL_R_OPTS="--bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"
export FZF_COMPLETION_TRIGGER='**' # .. followed by tab opens autocomplete
_fzf_comprun() {
  local command=$1
  shift
  case "$command" in
    cd)           fzf --preview 'tree -C {} | head -200'   "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview 'bat -n --color=always {}' "$@" ;;
  esac
}

### Plugins which don't work with antidote
source <(fzf --zsh)                       # Fancy auto-complete

### Antitode plugins
zstyle ':antidote:bundle' use-friendly-names 'yes'
zsh_plugins=~/.zsh_plugins
fpath=("$brew_dir/opt/antidote/share/antidote/functions" $fpath) # Lazy-load antidote from its functions directory.
autoload -Uz antidote

# Generate a new static file whenever .zsh_plugins.txt is updated.
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  antidote bundle <${zsh_plugins}.txt >|${zsh_plugins}.zsh
fi

# Source your static plugins file.
source ${zsh_plugins}.zsh
