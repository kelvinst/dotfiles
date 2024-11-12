.PHONY: clean install
all: clean install

install:
	mkdir -p ~/.config/kitty/
	cp ./.config/kitty/kitty.conf ~/.config/kitty/kitty.conf
	cp ./.gitconfig ~/
	cp ./.global_gitignore ~/
	cp ./.zshrc ~/
	zsh -c "source ~/.zshrc"

clean:
	rm -rf ~/.config/kitty/kitty.conf
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.zshrc

update: 
	mkdir -p ./.config/kitty/
	cp ~/.config/kitty/kitty.conf ./.config/kitty/kitty.conf
	cp ~/.gitconfig ./
	cp ~/.global_gitignore ./
	cp ~/.zshrc ./
