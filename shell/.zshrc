# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
source "$HOME/.shared_env"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="spaceship"

plugins=(git zsh-bat fzf-tab terraform aws)
setopt HIST_SAVE_NO_DUPS # Do not write a duplicate event to the history file.
# Lazy load nvm so it doesn't happen on every new termianl
# zstyle ':omz:plugins:nvm' lazy yes

brew_dir=$(brew --prefix)

source $ZSH/oh-my-zsh.sh
fpath+="$brew_dir/share/zshc/site-functions"

# Shared aliases and path options

# fnm (faster nvm)
eval "$(fnm env --use-on-cd --shell zsh)"

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
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export WF_DOCKER_REGISTRY="731837323691.dkr.ecr.us-east-1.amazonaws.com"
# AWS shit:
export AWS_PROFILE="ci"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_REGION="$AWS_DEFAULT_REGION"
export AWS_SDK_LOAD_CONFIG=1

alias awslogin='AWS_PROFILE=ci aws sts get-caller-identity >/dev/null 2>&1 || aws sso login --sso-session wf-session &>/dev/null && AWS_CONFIG_FILE="$HOME/.aws/config" yawsso'

alias ecrlogin_ci="AWS_PROFILE=ci aws ecr get-login-password --region us-east-1 | docker login --username AWS
--password-stdin 731837323691.dkr.ecr.us-east-1.amazonaws.com"

alias ecrlogin_dev="AWS_PROFILE=dev-publish-only aws ecr get-login-password region us-east-1 | docker login --username AWS
--password-stdin 024376647576.dkr.ecr.us-east-1.amazonaws.com"

function ecrlogin {
    ecrlogin_ci
    ecrlogin_dev
}

function bk_annotations {
    curl -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
        -X GET "https://api.buildkite.com/v2/organizations/webflow/pipelines/${2:-ci-plus-plus}/builds/$1/annotations"
}

function bk_build {
    curl -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
        -X GET "https://api.buildkite.com/v2/organizations/webflow/pipelines/${2:-ci-plus-plus}/builds/$1"
}

function bk_job {
    curl -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
        -X GET "https://api.buildkite.com/v2/organizations/webflow/pipelines/${3:-ci-plus-plus}/builds/$1/jobs/$2"
}

function bk_builds {
    curl -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
        -X GET "https://api.buildkite.com/v2/organizations/webflow/pipelines/${2:-ci-plus-plus}/builds/?$1"
}

function get_all_mq_builds {
    bk_builds "branch=gh-readonly-queue*"
}

function get_mq_builds {
    bk_builds "branch=gh-readonly-queue*&state=running" | jq -r'[].web_url'
}

function bk_agents {
    name_str=$(test $#-gt 0 && echo "?name=$1" || "")
    curl -H "Authorization: Bearer $BUILDKITE_API_TOKEN" \
        -X GET "https://api.buildkite.com/v2/organizations/webflow/agents$name_str"
}
