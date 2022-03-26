all: clean install

install:
	cp ./.alacritty.yml ~/
	cp ./.bash_profile ~/
	cp ./.zshrc ~/
	cp ./.ctags ~/
	cp ./.gitconfig ~/
	cp ./.global_gitignore ~/
	cp ./.iex.exs ~/
	cp ./.inputrc ~/
	cp ./.tmux.conf ~/
	cp ./.vimrc ~/
	cp -r ./.bin ~/
	cp -r ./.config/base16-shell ~/.config/
	cp -r ./.config/kitty ~/.config/
	cp -r ./.config/nvim ~/.config/
	cp -r ./.config/s ~/.config/
	cp -r ./.config/starship.toml ~/.config/
	cp -r ./.vim/after ~/.vim/
	cp -r ./.vim/coc-settings.json ~/.vim/

clean:
	rm -rf ~/.alacritty.yml
	rm -rf ~/.bash_profile
	rm -rf ~/.zshrc
	rm -rf ~/.ctags
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.iex.exs
	rm -rf ~/.inputrc
	rm -rf ~/.tmux.conf
	rm -rf ~/.vimrc
	rm -rf ~/.bin
	rm -rf ~/.config/base16-shell
	rm -rf ~/.config/kitty
	rm -rf ~/.config/nvim
	rm -rf ~/.config/s
	rm -rf ~/.config/starship.toml
	rm -rf ~/.vim/after
	rm -rf ~/.vim/coc-settings.json

