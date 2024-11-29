# NOTE: Third-party setups

# Setup starship
eval "$(starship init zsh)"

# Setup asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# Setup zsh-autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# NOTE: Aliases are defined in the zhsenv file (so that they work on vim zsh)

source ~/.zshenv

# NOTE: Env variables

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# Add rust bin to path
export PATH="$(asdf where rust)/bin:$PATH"

# Setting tmux-sessionizer config path
export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

# Default configs dir
export XDG_CONFIG_HOME="$HOME/.config"

# NOTE: Functions and Auto-commands

# Retries a command until it fails
flaky() {
  local try=1
  local cmd="$*"

  echo "Running flaky command: '$cmd'"
  
  while eval "$cmd"; do
    echo "Try #$try succeeded."
    try=$((try + 1))
  done
  
  echo "Try #$try failed."
  echo "Command output:"
  eval "$cmd" 2>&1
}

# Returns the current git branch
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Ring a bell on command failures
precmd() {
    if [[ $? -ne 0 ]]; then
        printf "\a"
    fi
}

# Show alias commands when executing them
_-accept-line () {
    emulate -L zsh
    local -a WORDS
    WORDS=( ${(z)BUFFER} )
    local -r FIRSTWORD=${WORDS[1]}
    local GRAY_FG=$'\e[37m' RESET_COLORS=$'\e[0m'
    [[ "$(whence -w $FIRSTWORD 2>/dev/null)" == "${FIRSTWORD}: alias" ]] &&
        echo -nE $'\n'"${GRAY_FG}# ↳ aka ${RESET_COLORS}$(whence $FIRSTWORD)"
    zle .accept-line
}
zle -N accept-line _-accept-line

