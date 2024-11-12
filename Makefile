.PHONY: clean install
all: clean install

install:
	cp ./.gitconfig ~/
	cp ./.global_gitignore ~/
	cp ./.zshrc ~/
	zsh -c "source ~/.zshrc"

clean:
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.zshrc

update: 
	cp ~/.gitconfig ./
	cp ~/.global_gitignore ./
	cp ~/.zshrc ./
