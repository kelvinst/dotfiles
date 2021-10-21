# dotfiles

My new dotfiles

## Installation

1. Install [brew](http://brew.sh)
1. Install basic tools I use:

```
brew install tmux
brew install reattach-to-user-namespace
brew install vim
brew install the_silver_searcher
brew install fzf
brew install fasd
```

1. Install [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh):

```
sh -c "$(curl -fsSL \
  https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

1. Install [typewritten for oh-my-zsh][typewritten]:

```
git clone https://github.com/reobin/typewritten.git \
  $ZSH_CUSTOM/themes/typewritten

ln -s "$ZSH_CUSTOM/themes/typewritten/typewritten.zsh-theme" \
  "$ZSH_CUSTOM/themes/typewritten.zsh-theme"
ln -s "$ZSH_CUSTOM/themes/typewritten/async.zsh" "$ZSH_CUSTOM/themes/async"
```

1. Install [Vundle.vim](https://github.com/gmarik/Vundle.vim):

```
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
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

[elixir-ls](https://github.com/elixir-lsp/coc-elixir#server-fails-to-start)
[typewritten](https://typewritten.dev/#/installation?id=oh-my-zsh)
