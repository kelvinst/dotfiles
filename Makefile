all: clean install

install:
	ln .ctags ~
	ln .gitconfig ~
	ln .tmux.conf ~
	ln .vimrc-new ~/.vimrc
	ln .spacemacs ~
	ln .bash_profile ~

clean:
	rm -rf ~/.ctags
	rm -rf ~/.gitconfig
	rm -rf ~/.tmux.conf
	rm -rf ~/.tmux.lightline
	rm -rf ~/.vimrc
	rm -rf ~/.spacemacs
	rm -rf ~/.bash_profile

