all: clean install

install:
	cp ./.alacritty.yml ~
	cp ./.bash_profile ~
	cp ./.zshrc ~
	cp ./.ctags ~
	cp ./.gitconfig ~
	cp ./.global_gitignore ~
	cp ./.iex.exs ~
	cp ./.inputrc ~
	cp ./.teex.exs ~
	cp ./.tmux.conf ~
	cp ./.vimrc-new ~/.vimrc
	cp -r ./.config/base16-shell ~/.config/
	cp -r ./.config/s ~/.config/
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
	rm -rf ~/.teex.exs
	rm -rf ~/.tmux.conf
	rm -rf ~/.vimrc
	rm -rf ~/.config/base16-shell
	rm -rf ~/.config/s
	rm -rf ~/.vim/after
	rm -rf ~/.vim/coc-settings.json

