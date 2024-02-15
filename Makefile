.PHONY: clean install
all: clean install

install:
	cp ./.alacritty.yml ~/
	cp ./.zshrc ~/
	cp ./.ctags ~/
	cp ./.gitconfig ~/
	cp ./.global_gitignore ~/
	cp ./.iex.exs ~/
	cp ./.inputrc ~/
	cp ./.tmux.conf ~/
	cp -r ./.bin ~/
	cp -r ./.config/kitty ~/.config/
	cp -r ./.config/s ~/.config/
	cp -r ./.config/starship.toml ~/.config/
	zsh -c "source ~/.zshrc"

clean:
	rm -rf ~/.alacritty.yml
	rm -rf ~/.zshrc
	rm -rf ~/.ctags
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.iex.exs
	rm -rf ~/.inputrc
	rm -rf ~/.tmux.conf
	rm -rf ~/.bin
	rm -rf ~/.config/kitty
	rm -rf ~/.config/s
	rm -rf ~/.config/starship.toml
	rm -rf ~/.vimrc
	rm -rf ~/.config/nvim
	rm -rf ~/.vim/after

install_old:
	cp ./.alacritty.yml ~/
	cp ./.zshrc ~/
	cp ./.ctags ~/
	cp ./.gitconfig ~/
	cp ./.global_gitignore ~/
	cp ./.iex.exs ~/
	cp ./.inputrc ~/
	cp ./.tmux.conf ~/
	cp -r ./.bin ~/
	cp -r ./.config/kitty ~/.config/
	cp -r ./.config/s ~/.config/
	cp -r ./.config/starship.toml ~/.config/
	cp ./old/.vimrc ~/
	cp -r ./old/.config/nvim ~/.config/
	cp -r ./old/.vim/after ~/.vim/

