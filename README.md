# dotfiles

My new dotfiles

## Installation

1. Install [brew](http://brew.sh)
1. Install basic tools I use:

```shell
brew install tmux
brew install reattach-to-user-namespace
brew install vim
brew install neovim
brew install the_silver_searcher
brew install fzf
brew install fasd
brew install direnv
brew install starship
brew install fig
```

1. Install [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh):

```shell
sh -c "$(curl -fsSL \
  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

1. Install [tpm](https://github.com/tmux-plugins/tpm):

```shell
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

1. Install all plugins on tmux by reloading .tmux.conf (prefix+R) and 
installing the plugins (prefix+I)

1. Install [base16-shell](https://github.com/chriskempson/base16-shell):

```shell
git clone https://github.com/chriskempson/base16-shell.git ~/.config/base16-shell
```

1. Install [zsh-autosuggestions][zsh-autosuggestions]:

```shell
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
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

1. Install [elixir-ls from source][elixir-ls] (remember to do this with the 
lowest elixir and erlang of all the projects):

```
git clone https://github.com/elixir-lsp/elixir-ls.git ~/.elixir-ls
cd ~/.elixir-ls
mix deps.get && mix compile && mix elixir_ls.release -o release
```

1. Install [Vundle.vim](https://github.com/gmarik/Vundle.vim):

```shell
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

1. Install plugins on vim with `:PluginInstall`


[elixir-ls]: https://github.com/elixir-lsp/coc-elixir#server-fails-to-start
[zsh-autosuggestions]: https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md
