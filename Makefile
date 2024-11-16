jk.PHONY: clean install
all: clean install

install:
	mkdir -p ~/.config/kitty/
	cp ./config/kitty/* ~/.config/kitty/
	mkdir -p ~/.config/nvim/
	cp -r ./config/kickstart.nvim/* ~/.config/nvim/
	cp ./gitconfig ~/.gitconfig
	cp ./global_gitignore ~/.global_gitignore
	cp ./tmux.conf ~/.tmux.conf
	cp ./zshrc ~/.zshrc

clean:
	rm -rf ~/.config/kitty/*
	rm -rf ~/.config/nvim/*
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.tmux.conf
	rm -rf ~/.zshrc

update: 
	mkdir -p ./config/kitty/
	cp -r ~/.config/kitty/* ./config/kitty/
	mkdir -p ./config/nvim/
	cp -r ~/.config/nvim/* ./config/kickstart.nvim/
	cp ~/.gitconfig ./gitconfig
	cp ~/.global_gitignore ./global_gitignore
	cp ~/.tmux.conf ./tmux.conf
	cp ~/.zshrc ./zshrc
