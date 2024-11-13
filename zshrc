# running starship, to make the prompt a bit prettier
eval "$(starship init zsh)"

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# running asdf config
. /opt/homebrew/opt/asdf/libexec/asdf.sh

