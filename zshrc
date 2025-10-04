# NOTE: Env variables

# My preferred editor
export EDITOR='nvim'

# Add local bin to the beginning of PATH
export PATH="$HOME/.local/bin:$PATH"

# Add homebrew bins to the beginning of PATH
export PATH="/opt/homebrew/bin:$PATH"

# Add rust bin to path
export PATH="$(asdf where rust)/bin:$PATH"

# Setting tmux-sessionizer config path
export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

# Default configs dir
export XDG_CONFIG_HOME="$HOME/.config"

# Coloring files
export LS_COLORS="$(vivid generate tokyonight-moon)"

# NOTE: Completions

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
export FPATH=(/Users/kelvinstinghen/.docker/completions $fpath)

# Configure additional completion definitions
fpath=$(brew --prefix)/share/zsh-completions:$FPATH

# Load the completion system
autoload -Uz compinit
compinit

# Load the amazing tab completion fuzzy finder
source ~/.fzf-tab/fzf-tab.plugin.zsh

source ~/.fzf-tab-source/*.plugin.zsh

# All these are configurations for the fuzzy finder completion tool
# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# Set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# Set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# Preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
# Preview for many git subcommands
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'case "$group" in "commit tag") git show --color=always $word ;; *) git show --color=always $word | delta ;; esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'case "$group" in "modified file") git diff $word | delta ;; "recent commit object name") git show --color=always $word | delta ;; *) git log --color=always $word ;; esac'
# Space to accept the selection
zstyle ':fzf-tab:*' fzf-flags --bind=space:accept
# Switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# Suggest commands as you type
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# NOTE: General shell improvements

# Syntax highlightning for the shell commands
source ~/.fsyh/fast-syntax-highlighting.plugin.zsh

# The command line prompt
eval "$(starship init zsh)"

# The better `cd` command
eval "$(zoxide init zsh)"

# NOTE: Dev stuff

# The runtime version manager
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# NOTE: Aliases

# alias
alias a='aliases'

# bat
alias b='bat'

# clear
alias c='clear'

# eza
alias ez='eza'
alias e='eza -Gla'

# git
alias g='git_status_or_git'
alias gg='git status -sb'
alias ga='git add --verbose'
alias gc='git commit --verbose'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph'
alias gp='git push'
alias gpsup="git push --set-upstream origin \$(git_current_branch)"
alias gpf='git push --force-with-lease --force-if-includes'
alias gr='git reset'
alias gu='git pull'

# lazygit
alias lazygit='[ -n "$TMUX" ] && tmux setw monitor-activity off \; lazygit'
alias lg='lazygit'

# ls
alias ls="gls --color"
alias l='ls -Gla'

# make
alias m='make'

# source
alias s='source'
alias sz='source ~/.zshrc && source ~/.zshenv'

# tmux
alias t='tmux'

# vim/nvim
alias v='nvim'

# Remove some useless predefined aliases
unalias -m run-help
unalias -m which-command

# NOTE: Functions

# Searches for aliases
aliases() {
  if [[ -z $1 ]]; then
    alias
  else
    alias | rg $1
  fi
}

# Shows `git status -sb` if no arguments are given, otherwise runs `git` with the provided arguments
git_status_or_git() {
  if [[ $# -eq 0 ]]; then
    git status -sb
  else
    git "$@"
  fi
}

# Returns the current git branch
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Retries a command until it fails
flaky() {
  local attempt=1
  local temp_file=$(mktemp)

  # Define color codes
  local green="\033[32m"
  local reset="\033[0m"

  echo -e "Running flaky command: ${green}$*${reset}"

  while true; do
    printf "\rAttempt ${green}#$attempt${reset}..."

    # Use 'script' to capture colored output
    if ! script -q $temp_file $* > /dev/null 2>&1; then
      echo
      printf "\nFailed command output:\n"
      cat "$temp_file"
      rm -f "$temp_file"
      break
    fi
    attempt=$((attempt + 1))
  done
}

# NOTE: Auto-commands

# Ring a bell on command failures
precmd() {
    if [[ $? -ne 0 ]]; then
        printf "\a"
    fi
}

# Show alias commands when executing them
_-accept-line () {
    emulate -L zsh

    local -a words
    words=( ${(z)BUFFER} )
    local -r firstword=${words[1]}

    # Some colors for the output
    local gray=$'\e[37m' 
    local reset=$'\e[0m'

    [[ "$(whence -w $firstword 2>/dev/null)" == "${firstword}: alias" ]] &&
        echo -nE $'\n'"${gray}  ↳ aka ${reset}$(whence $firstword)"
    zle .accept-line
}
zle -N accept-line _-accept-line

