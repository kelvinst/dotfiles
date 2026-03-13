# vim:fileencoding=utf-8:foldmethod=marker

# WARNING: This file is loaded for all zsh invocations, including
# non-interactive ones. So whatever you need for headless zsh, put it
# here. e.g. skhd keyboard shortcuts

# NOTE: Env variables {{{

# Add local bin to the beginning of PATH
export PATH="$HOME/.local/bin:$PATH"

# Add homebrew bins to the beginning of PATH
export PATH="$(brew --prefix)/bin:$PATH"

# Add rust bin to path
export PATH="$(asdf where rust)/bin:$PATH"

# Add npm bin to path
export PATH="$(asdf where nodejs)/.npm/bin:$PATH"

# Add opencode bin to path
export PATH="$HOME/.opencode/bin:$PATH"

# Add postgres bins to path
export PATH="$(brew --prefix)/opt/postgresql@18/bin:$PATH"

# }}}
