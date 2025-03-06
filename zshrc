# NOTE: Third-party setups

# Setup starship
eval "$(starship init zsh)"

# Setup asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Setup zsh-autosuggestions
source $(/opt/homebrew/bin/brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# NOTE: Env variables

# Preferred editor nvim if exists
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Add homebrew bins to the beginning of PATH
export PATH="/opt/homebrew/bin:$PATH"

# Add rust bin to path
export PATH="$(asdf where rust)/bin:$PATH"

# Setting tmux-sessionizer config path
export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

# Default configs dir
export XDG_CONFIG_HOME="$HOME/.config"

# NOTE: Aliases

# clear
alias c='clear'

# git
alias g='git status -sb'
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
alias lazygit='tmux setw monitor-activity off && lazygit'
alias lg='lazygit'

# ls
alias l='ls -Gla'

# make
alias m='make'

# tmux
alias t='tmux'

# vim/nvim
alias v='nvim'

# zsh
alias z='source ~/.zshrc'

# Remove some useless predefined aliases
unalias -m run-help
unalias -m which-command

# NOTE: Functions

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

# Returns the current git branch
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
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
