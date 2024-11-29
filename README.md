# dotfiles

My new, simplified, dotfiles

## Installation

1. Install [brew](http://brew.sh)

```shell
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

1. Install the languages and package managers:

```shell
brew install asdf
asdf plugin-add elixir
asdf install elixir latest
asdf global elixir latest
asdf plugin-add erlang
asdf install erlang latest
asdf global erlang latest
asdf plugin-add rust
asdf install rust latest
asdf global rust latest
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

1. Install [kitty](https://sw.kovidgoyal.net/kitty)

```shell
brew install kitty
```

1. Install [starship](https://starship.rs/)

```shell
brew install starship
```

1. Install [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md#homebrew)

```shell
brew install zsh-autosuggestions
```

1. Install [tmux](https://github.com/tmux/tmux) and [tpm](https://github.com/tmux-plugins/tpm)

```shell
brew install tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

1. Install [tmux-sessionizer](https://github.com/jrmoulton/tmux-sessionizer):

```shell
cargo install tmux-sessionizer
```

1. Install [neovim](https://neovim.io)

```shell
brew install neovim
```

1. Follow the steps in [config/nvim/README.md](config/nvim/README.md)

1. Clone this repo and run `make` to install:

```shell
git clone https://github.com/kelvinst/dotfiles
cd dotfiles
make install
```

Feel free to fork and clone it from there. This is under MIT license, do what you want, just
give me some credit for it. 😁

## FAQ

- How to uninstall?
    - Just `make clean`, that's it
- I changed the files in here, how to reinstall?
    - Just run `make`, it will clean the files in your home and copy them again
- I changed the files in my home dir, how do I copy them here?
    - Just run `make update`, and we will copy your config files back in here
