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

1. You need to `make` `less` `git`! `unzip` your `gcc`, `catimg` `jq` `git-lfs`:

    ```shell
    brew install make less git unzip gcc jq catimg git-lfs
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

1. Install the modern replace for ls: [`eza`](https://github.com/eza-community/eza)

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

1. Install the per folder `.env` file loader: [`direnv`](https://direnv.net/)

    ```shell
    brew install direnv
    ```

1. Install "FiraCode Nerd Font Mono" from [here](https://www.nerdfonts.com/)

1. Install the runtime version manager: [`mise`](https://mise.jdx.dev)

    ```shell
    brew install mise
    ```

1. Install runtimes for `elixir`, `erlang`, `rust`, `python`, `node`, `yarn`, `just` and `zig`:

    ```shell
    mise use -g elixir@latest
    mise use -g erlang@latest
    mise use -g rust@latest
    mise use -g python@latest
    mise use -g node@latest
    mise use -g yarn@latest
    mise use -g just@latest
    mise use -g zig@latest
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

1. Install [Amethyst](https://github.com/ianyh/Amethyst)

    ```shell
    brew install --cask amethyst
    ```

1. Install [skhd](https://github.com/koekeishiya/skhd)

    ```shell
    brew install koekeishiya/formulae/skhd
    ```

1. Install [JankyBorders](https://github.com/FelixKratz/JankyBorders)

    ```shell
    brew tap FelixKratz/formulae && brew install borders
    ```

1. Install [ai-jail](https://github.com/akitaonrails/ai-jail)

    ```shell
    brew tap akitaonrails/tap && brew install ai-jail
    ```

1. Install the worktree manager: [`worktrunk`](https://github.com/0k-software/worktrunk)

    ```shell
    brew install worktrunk
    ```

1. Install the code formatter: [`prettier`](https://prettier.io)

    ```shell
    npm install -g prettier
    ```

1. Install [claude code](https://claude.com/product/claude-code)

    ```shell
    curl -fsSL https://claude.ai/install.sh | bash
    ```

1. Install [claude code acp](https://github.com/zed-industries/claude-code-acp)

    ```shell
    npm install -g @zed-industries/claude-code-acp
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
