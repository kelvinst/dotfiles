# NOTE: Third-party setups

# Setup starship
eval "$(starship init zsh)"

# Setup asdf
. /opt/homebrew/opt/asdf/libexec/asdf.sh

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
alias gpf='git push --force-with-lease --force-if-includes'
alias gr='git reset'
alias gu='git pull'

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
