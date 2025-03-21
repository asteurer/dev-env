# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

##########################################################################
# CUSTOM
##########################################################################

#-------------------------------------------------------------------------
# Misc
#-------------------------------------------------------------------------

# Update
alias update="sudo dnf update && rustup update"

#-------------------------------------------------------------------------
# Golang
#-------------------------------------------------------------------------

export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:$HOME/go/bin

#-------------------------------------------------------------------------
# Python
#-------------------------------------------------------------------------

# Python shortcut
alias py="python3"
alias python="python3"

#-------------------------------------------------------------------------
# Kubernetes
#-------------------------------------------------------------------------

alias k="kubectl"
# Gather all the paths in ~/.kube that end with ".config" and join them with colons (and removing trailing colon)
alias kauth='export KUBECONFIG="$(find ~/.kube -type f -name "*.config" -printf "%p:")"; export KUBECONFIG="${KUBECONFIG%:}"'
alias kdebug="kubectl run -i --rm --tty debug --image=alpine --restart=Never -- sh"
alias kctx="kubectl config use-context"

#-------------------------------------------------------------------------
# Git
#-------------------------------------------------------------------------

# Git aliases
alias giad="git add"
alias gist="git status"
alias gich="git checkout"
alias gico="git commit -sm"
alias gire="git rebase"
alias gibr="git --no-pager branch"
# alias gill="git pull origin"
# alias gish="git push origin"
# alias gilo="git log --oneline"
# alias gilop="git log -p"
# alias gidi="git diff"
# alias gidiw="git diff --word-diff"
# alias giadp="git add --patch"
# alias gico="git commit -s -S"
# alias gicoa="git commit -s -S --amend"
# alias gicl="git clean -di"
# alias yolo="git add . && git commit -m"
# alias gigr='git log --graph --abbrev-commit --decorate --all --format=format:"%C(bold blue)%h%C(reset) \
#     - %C(bold cyan)%aD%C(dim white) - \
#     %an%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n %C(white)%s%C(reset)"'
# alias gisync="git pull upstream main --rebase"
# alias gireflog="git reflog HEAD@{now}"
# girei() { git rebase -i HEAD~$1 }


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh