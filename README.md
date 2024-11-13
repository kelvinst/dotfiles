# dotfiles

My new, simplified, dotfiles

## Installation

1. Isntall [kitty](https://sw.kovidgoyal.net/kitty)
1. Install [brew](http://brew.sh)
1. Install [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)
1. Install [neovim](https://neovim.io). Prefer the 
[homebrew](https://github.com/neovim/neovim/blob/master/INSTALL.md#homebrew-on-macos-or-linux) way: 

```
brew install neovim
```

1. Install the languages and package managers:

```
brew install asdf
asdf plugin-add elixir
asdf install elixir latest
asdf global elixir latest
asdf plugin-add erlang
asdf install erlang latest
asdf global erlang latest
asdf plugin-add python
asdf install python latest
asdf global python latest
asdf plugin-add nodejs
asdf install nodejs latest
asdf global nodejs latest
asdf plugin-add yarn
asdf install yarn latest
asdf global yarn latest
```

