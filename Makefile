all: clean install

install:
	cp .alacritty.yml ~
	cp .bash_profile ~
	cp .zshrc ~
	cp .ctags ~
	cp .gitconfig ~
	cp .global_gitignore ~
	cp .iex.exs ~
	cp .inputrc ~
	cp .teex.exs ~
	cp .tmux.conf ~
	cp .vimrc-new ~/.vimrc
	cp -r .config ~/.config
	mkdir ~/.config/nvim/
	cp .vimrc-new ~/.config/nvim/init.vim
	cp -r .vim/after ~/.vim/

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
	rm -rf ~/.config
	rm -rf ~/.vim/after

