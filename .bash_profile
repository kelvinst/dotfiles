# vi mode
set -o vi

# escape timeout
export KEYTIMEOUT=1

# to get the binstubs on ./bin and a lot of other places
export PATH="./bin:/usr/local/opt/make/libexec/gnubin:$PATH"
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

[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion

# source <(kubectl completion bash)

. $HOME/.asdf/asdf.sh
. $HOME/.asdf/completions/asdf.bash
