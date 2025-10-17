# dotfiles

My new, simplified, dotfiles

## Installation

1. Install the terminal: [`kitty`](https://sw.kovidgoyal.net/kitty)

    ```shell
    brew install kitty
    ```

1. Install Mac package manager: [`brew`](http://brew.sh)

    ```shell
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    ```

1. You need to `make` `less` `git`! `unzip` your `gcc`, `catimg` `jq`:

    ```shell
    brew install make less git unzip gcc jq catimg
    ```

1. Install GNU scripts, for better general tools: [`coreutils`](https://www.gnu.org/software/coreutils/)

    ```shell
    brew install coreutils
    ```

1. Install a better git diff tool: [`git-delta`](diff-so-fancy)

    ```shell
    brew install git-delta
    ```

1. Install the universal file converter: [`pandoc`](https://pandoc.org)

    ```shell
    brew install pandoc
    ```

1. Install the prompt: [`starship`](https://starship.rs/)

    ```shell
    brew install starship
    ```

1. Install the fuzzy-finder: [`fzf`](https://github.com/junegunn/fzf)

    ```shell
    brew install fzf
    ```

1. Install the smarter cd command: [`zoxide`](https://github.com/ajeetdsouza/zoxide)

    ```shell
    brew install zoxide
    ```

1. Isntall the modern replace for ls: [`eza`](https://github.com/eza-community/eza)

    ```shell
    brew install eza
    ```

1. Install the cat replacement (with wings): [`bat`](https://github.com/sharkdp/bat)

    ```shell
    brew install bat
    ```

1. Install the corn for basic shell commands (the output colorizer): [`grc`][grc]

    ```shell
    brew install grc
    ```

1. Install file colors config generator: [`vivid`](https://github.com/sharkdp/vivid)

    ```shell
    brew install vivid
    ```

1. Install shell syntax highlightning: [`fast-syntax-highlighting`][fast-syntax-highlighting]

    ```shell
    git clone https://github.com/zdharma-continuum/fast-syntax-highlighting ~/.fsyh
    ```

1. Install base completions: [`zsh-completions`](https://github.com/zsh-users/zsh-completions)

    ```shell
    brew install zsh-completions
    ```

1. Install suggestions as you type: [`zsh-autosuggestions][zsh-autosuggestions`]

    ```shell
    brew install zsh-autosuggestions
    ```

1. Install a better completion UI: [`fzf-tab`](https://github.com/Aloxaf/fzf-tab)

    ```shell
    git clone https://github.com/Aloxaf/fzf-tab ~/.fzf-tab
    ```

1. Install some premade configs for fzf-tab: [`fzf-tab-source`][fzf-tab-source]

    ```shell
    git clone https://github.com/Freed-Wu/fzf-tab-source ~/.fzf-tab-source
    ```

1. Install the fzf-tab binary module to speed up coloring: ([for reference][fzf-tab-bin-module]):

    ```shell
    build-fzf-tab-module
    ```

1. Install the lord of terminal multiplexers: [`tmux`](https://github.com/tmux/tmux) 

    ```shell
    brew install tmux
    ```

1. Install its package manager: [`tpm`](https://github.com/tmux-plugins/tpm)

    ```shell
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    ```

1. Install the way to load project sessions into it: [`tmux-sessionizer`][tmux-sessionizer]

    ```shell
    cargo install tmux-sessionizer
    ```

1. Install the searcher: [`ripgrep`](https://github.com/BurntSushi/ripgrep)

    ```shell
    brew install ripgrep
    ```

1. Install "FiraCode Nerd Font Mono" from [here](https://www.nerdfonts.com/)

1. Install the runtime version manager: [`asdf`](https://asdf-vm.com)

    ```shell
    brew install asdf
    ```

1. Install the plugins for `elixir`, `erlang`, `rust`, `python`, `nodejs` and `yarn`:

    ```shell
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


1. Install [`neovim`](https://neovim.io)

    ```shell
    brew install neovim
    ```

1. Install [`nvim_url`](https://github.com/kelvinst/nvim_url):

    ```shell
   git clone https://github.com/kelvinst/nvim_url.git
   cd nvim_url
   make install
   ```

1. Install [yabai](https://github.com/koekeishiya/yabai/wiki#yabai)

    ```shell
    brew install koekeishiya/formulae/yabai
    ```

1. Install [skhd](https://github.com/koekeishiya/skhd)

    ```shell
    brew install koekeishiya/formulae/skhd
    ```

1. Install [claude code](https://github.com/anthropics/claude-code)

    ```shell
    npm install -g @anthropic-ai/claude-code
    ```

1. Install [claude code acp](https://github.com/zed-industries/claude-code-acp)

    ```shell
    npm install -g @zed-industries/claude-code-acp
    ```

1. Create a claude code OAuth token with `claude setup-token`

1. Copy the token and add it to your `~/.zsh_private` file like this:

    ```shell
    export CLAUDE_CODE_OAUTH_TOKEN=<your_token_here>
    ```

1. Clone this repo and run `make` to install:

    ```shell
    git clone git@github.com:kelvinst/dotfiles.git
    cd dotfiles
    make install
    ```

Feel free to fork and clone it from there. This is under MIT license, do what 
you want, just give me some credit for it. 😁

## FAQ

- How to uninstall?
    - Just `make clean`, that's it
- I changed the files in here, how to reinstall?
    - Just run `make`, it will clean the files in your home and copy them again
- I changed the files in my home dir, how do I copy them here?
    - Just run `make update`, and we will copy your config files back in here

[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
[tmux-sessionizer](https://github.com/jrmoulton/tmux-sessionizer)
[fast-syntax-highlighting](https://github.com/zdharma-continuum/fast-syntax-highlighting)
[fzf-tab-source](https://github.com/Freed-Wu/fzf-tab-source)
[fzf-tab-bin-module](https://github.com/Aloxaf/fzf-tab?tab=readme-ov-file#binary-module)
[grc](https://github.com/garabik/grc)
