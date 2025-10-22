# NOTE: Env variables

# My preferred editor
export EDITOR='nvim'

# URL scheme for opening files in nvim from other applications
export PLUG_EDITOR="nvim://file/__FILE__:__LINE__"

# Add local bin to the beginning of PATH
export PATH="$HOME/.local/bin:$PATH"

# Add homebrew bins to the beginning of PATH
export PATH="/opt/homebrew/bin:$PATH"

# Add rust bin to path
export PATH="$(asdf where rust)/bin:$PATH"

# Add opencode bin to path
export PATH="$HOME/.opencode/bin:$PATH"

# Setting tmux-sessionizer config path
export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

# Default configs dir
export XDG_CONFIG_HOME="$HOME/.config"

# Coloring files
export LS_COLORS="$(vivid generate tokyonight-moon)"

# NOTE: Completions

# Configure additional completion definitions
export FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/kelvinstinghen/.docker/completions $fpath)

# Load the completion system
autoload -Uz compinit
compinit

# Load the amazing tab completion fuzzy finder
source ~/.fzf-tab/fzf-tab.plugin.zsh
source ~/.fzf-tab-source/*.plugin.zsh

# Command prompt formatter starship
eval "$(starship completions zsh)"

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

# `z` - the fuzzy `cd`
eval "$(zoxide init zsh)"

# Use shell vim mode
bindkey -v

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
alias g='git'
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
alias lg='lazygit'

# ls
alias ls='gls'
alias lc='ls --color'
alias l='lc --color -Gla'

# make
alias m='make'

# source
alias s='source'
alias sz='source ~/.zshrc && source ~/.zshenv'

# tmux
alias t='tmux'

# vim/nvim
alias nvim='nvim --listen /tmp/nvim-$(date +%s%N)'
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
git() {
  if [[ $# -eq 0 ]]; then
    command git status -sb
  else
    command git "$@"
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
show_alias_feedback() {
  local -a words
  words=( ${(z)1} )  # $1 contains the command string
  local -r cmd=${words[1]}

  # Color codes
  local gray=$'\e[37m' 
  local white=$'\e[97;1m'
  local blue=$'\e[34;1m'
  local red=$'\e[31;1m'
  local green=$'\e[32;1m'
  local nc=$'\e[0m'

  local cmd_desc=$(whence -v $cmd 2>/dev/null)

  # Remove the "cmd is " or "cmd " prefix
  cmd_desc=${cmd_desc#$cmd is }
  cmd_desc=${cmd_desc#$cmd }

  # Apply formatting based on content
  if [[ $cmd_desc == "not found" ]]; then
    cmd_desc="${red}not found"
  elif [[ $cmd_desc =~ "^an alias for (.+)$" ]]; then
    local alias_target="${match[1]}"
    cmd_desc="an ${blue}alias${gray} for ${green}${alias_target}"
  elif [[ $cmd_desc =~ "^a shell builtin$" ]]; then
    cmd_desc="a shell ${blue}builtin"
  elif [[ $cmd_desc =~ "^a shell function$" ]]; then
    cmd_desc="a shell ${blue}${match[1]}"
  elif [[ $cmd_desc =~ "^an autoload shell function$" ]]; then
    cmd_desc="an ${blue}autoload${gray} shell ${blue}function"
  elif [[ $cmd_desc =~ "^an autoload shell function from (.+)$" ]]; then
    local path="${match[1]}"
    cmd_desc="an ${blue}autoload${gray} shell ${blue}function${gray} from ${green}${path}"
  elif [[ $cmd_desc =~ "^a shell function from (.+)$" ]]; then
    local path="${match[1]}"
    cmd_desc="a shell ${blue}function${gray} from ${green}${path}"
  elif [[ $cmd_desc =~ "^a reserved word$" ]]; then
    cmd_desc="a ${blue}reserved${gray} word"
  elif [[ $cmd_desc =~ "^/.*$" ]]; then
    cmd_desc="located at ${green}${cmd_desc}"
  fi

  # Wrap entire description in gray
  cmd_desc="${gray}${cmd_desc}${nc}"

  echo "${gray}┏ running ${white}$cmd ${gray}(${nc}$cmd_desc${gray})$nc"
}

# Add to preexec functions (runs before command execution)
preexec_functions+=(show_alias_feedback)

# Function to load the solid starship prompt
load_solid_prompt() {
  export STARSHIP_CONFIG=$HOME/.config/starship/solid.toml
  source $HOME/.config/starship/init.sh
}

# Load solid prompt before each command
precmd_functions+=(load_solid_prompt)

# Function to set the transparent prompt
load_transparent_prompt() {
  export STARSHIP_CONFIG=$HOME/.config/starship/transparent.toml
  source $HOME/.config/starship/init.sh
  
  # Override PROMPT to show nothing if no command was executed
  if [[ -z "$STARSHIP_DURATION" ]]; then
    PROMPT=''
  fi
  
  zle .reset-prompt
}

# Load transparent prompt when a line is finished
zle -N zle-line-finish load_transparent_prompt
trap 'load_transparent_prompt; return 130' INT

# NOTE: Load private zshrc if it exists

if [ -f ~/.zshrc_private ]; then
  source ~/.zshrc_private
fi

