# vi mode
set -o vi

# alias for vim sessions
alias v='vim -S'
alias nv='nvim -S'

# alias for tmux sessions
function t() {
  dir_name=${PWD##*/}
  handled_name=${dir_name/\./}
  project_name=${1:-$handled_name}
  
  tmux attach -d -t $project_name || tmux new -s $project_name
}

export LC_ALL=en_US.UTF-8

# escape timeout
export KEYTIMEOUT=1

# to get the binstubs on ./bin and a lot of other places
export PATH="/sbin:/bin:/usr/games:/usr/local/games:$PATH"
export PATH="/usr/local/opt/elasticsearch@2.4/bin:$PATH"
export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"
export PATH="$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"

# vim as the default editor
export EDITOR="vim"

# hub aliased as git
eval "$(hub alias -s)"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/kelvinst/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/kelvinst/google-cloud-sdk/path.zsh.inc'; fi

export GOPATH="~/.go"
export ANDROID_HOME="/Users/kelvinst/Library/Android/sdk/"
export PATH="$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools"
export PATH="$PATH:${HOME}/.zsh_functions"

# source <(kubectl completion zsh)

. $(brew --prefix asdf)/asdf.sh

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

# disable flow control
stty -ixon

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/"
[ -n "$PS1" ] && [ -s "$BASE16_SHELL/profile_helper.sh" ] && eval "$("$BASE16_SHELL/profile_helper.sh")"
base16_eighties
