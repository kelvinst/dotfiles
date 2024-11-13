.PHONY: clean install
all: clean install

install:
	mkdir -p ~/.config/kitty/
	cp ./.config/kitty/kitty.conf ~/.config/kitty/kitty.conf
	cp -r ./.config/kickstart.nvim/* ~/.config/nvim/
	cp ./gitconfig ~/.gitconfig
	cp ./global_gitignore ~/.global_gitignore
	cp ./zshrc ~/.zshrc

clean:
	rm -rf ~/.config/kitty/kitty.conf
	rm -rf ~/.config/nvim/*
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.zshrc

update: 
	mkdir -p ./.config/kitty/
	cp ~/.config/kitty/kitty.conf ./.config/kitty/kitty.conf
	cp -r ~/.config/nvim/* ./.config/kickstart.nvim/
	cp ~/.gitconfig ./gitconfig
	cp ~/.global_gitignore ./global_gitignore
	cp ~/.zshrc ./zshrc
