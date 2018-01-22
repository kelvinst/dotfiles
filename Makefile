all: clean install

install:
	ln .bash_profile ~
	ln .ctags ~
	ln .gitconfig ~
	ln .inputrc ~
	ln .tmux.conf ~
	ln .vimrc-new ~/.vimrc

clean:
	rm -rf ~/.bash_profile
	rm -rf ~/.ctags
	rm -rf ~/.gitconfig
	rm -rf ~/.inputrc
	rm -rf ~/.tmux.conf
	rm -rf ~/.vimrc

