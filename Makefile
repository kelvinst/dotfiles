.PHONY: clean install
all: clean install

install:
	mkdir -p ~/.config/kitty/
	cp -r ./config/kitty/* ~/.config/kitty/
	mkdir -p ~/.config/nvim/
	cp -r ./config/nvim/* ~/.config/nvim/
	mkdir -p ~/.config/tms/
	cp -r ./config/tms/* ~/.config/tms/
	mkdir -p ~/.hammerspoon/
	cp -r ./hammerspoon/* ~/.hammerspoon/
	cp -r ./config/init_starship.sh ~/.config/
	cp -r ./config/starship.toml ~/.config/
	cp ./gitconfig ~/.gitconfig
	cp ./global_gitignore ~/.global_gitignore
	cp ./skhdrc ~/.skhdrc
	cp ./tmux.conf ~/.tmux.conf
	cp ./zshrc ~/.zshrc
	cp ./zshenv ~/.zshenv

clean:
	rm -rf ~/.config/kitty/*
	rm -rf ~/.config/nvim/*
	rm -rf ~/.config/tms/*
	rm -rf ~/.hammerspoon/*
	rm -rf ~/.config/init_starship.sh
	rm -rf ~/.config/starship.toml
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.skhdrc
	rm -rf ~/.tmux.conf
	rm -rf ~/.zshrc
	rm -rf ~/.zshenv

update: 
	mkdir -p ./config/kitty/
	cp -r ~/.config/kitty/* ./config/kitty/
	mkdir -p ./config/nvim/
	cp -r ~/.config/nvim/* ./config/nvim/
	mkdir -p ./config/tms/
	cp -r ~/.config/tms/* ./config/tms/
	mkdir -p ./hammerspoon
	cp -r ~/.config/init_starship.sh ./config/
	cp -r ~/.config/starship.toml ./config/
	cp -r ~/.hammerspoon/* ./hammerspoon/
	cp ~/.gitconfig ./gitconfig
	cp ~/.global_gitignore ./global_gitignore
	cp ~/.skhdrc ./skhdrc
	cp ~/.tmux.conf ./tmux.conf
	cp ~/.zshrc ./zshrc
	cp ~/.zshenv ./zshenv
