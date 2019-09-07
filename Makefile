all: clean install

install:
	cp .bash_profile ~
	cp .ctags ~
	cp .gitconfig ~
	cp .inputrc ~
	cp .tmux.conf ~
	cp .vimrc-new ~/.vimrc
	cp -r .config ~/.config
	cp -r .vim/after ~/.vim/

clean:
	rm -rf ~/.bash_profile
	rm -rf ~/.ctags
	rm -rf ~/.gitconfig
	rm -rf ~/.inputrc
	rm -rf ~/.tmux.conf
	rm -rf ~/.vimrc
	rm -rf ~/.config
	rm -rf ~/.vim/after

