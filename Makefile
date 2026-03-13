.PHONY: clean install
all: clean install

install:
	mkdir -p ~/.claude/skills/
	mkdir -p ~/.codex/skills/
	cp -r ./ai/skills/* ~/.claude/skills/
	cp -r ./ai/skills/* ~/.codex/skills/
	mkdir -p ~/.config/direnv/
	cp -r ./config/direnv/* ~/.config/direnv/
	mkdir -p ~/.config/kitty/
	cp -r ./config/kitty/* ~/.config/kitty/
	mkdir -p ~/.config/nvim/
	cp -r ./config/nvim/* ~/.config/nvim/
	mkdir -p ~/.config/tms/
	cp -r ./config/tms/* ~/.config/tms/
	mkdir -p ~/.config/tidewave/
	cp -r ./config/tidewave/* ~/.config/tidewave/
	mkdir -p ~/.hammerspoon/
	cp -r ./hammerspoon/* ~/.hammerspoon/
	cp -r ./config/init_starship.sh ~/.config/
	cp -r ./config/starship.toml ~/.config/
	cp ./default-gems ~/.default-gems
	cp ./gitconfig ~/.gitconfig
	cp ./global_gitignore ~/.global_gitignore
	cp ./paneru.toml ~/.paneru.toml
	cp ./skhdrc ~/.skhdrc
	cp ./tmux.conf ~/.tmux.conf
	cp ./zshenv ~/.zshenv
	cp ./zshrc ~/.zshrc

clean:
	rm -rf ~/.claude/skills/*
	rm -rf ~/.codex/skills/*
	rm -rf ~/.config/direnv/*
	rm -rf ~/.config/kitty/*
	rm -rf ~/.config/nvim/*
	rm -rf ~/.config/tms/*
	rm -rf ~/.config/tidewave/*
	rm -rf ~/.hammerspoon/*
	rm -rf ~/.config/init_starship.sh
	rm -rf ~/.config/starship.toml
	rm -rf ~/.default-gems
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.paneru.toml
	rm -rf ~/.skhdrc
	rm -rf ~/.tmux.conf
	rm -rf ~/.zshenv
	rm -rf ~/.zshrc

update:
	mkdir -p ./ai/skills/
	cp -r ~/.claude/skills/* ./ai/skills/
	# We have to decide which one to copy here
	# cp -r ~/.codex/skills/* ./ai/skills/
	mkdir -p ./config/direnv/
	cp -r ~/.config/direnv/* ./config/direnv/
	mkdir -p ./config/kitty/
	cp -r ~/.config/kitty/* ./config/kitty/
	mkdir -p ./config/nvim/
	cp -r ~/.config/nvim/* ./config/nvim/
	mkdir -p ./config/tms/
	cp -r ~/.config/tms/* ./config/tms/
	mkdir -p ./config/tidewave/
	cp -r ~/.config/tidewave/* ./config/tidewave/
	mkdir -p ./hammerspoon
	cp -r ~/.config/init_starship.sh ./config/
	cp -r ~/.config/starship.toml ./config/
	cp -r ~/.hammerspoon/* ./hammerspoon/
	cp ~/.default-gems ./default-gems
	cp ~/.gitconfig ./gitconfig
	cp ~/.global_gitignore ./global_gitignore
	cp ~/.paneru.toml ./paneru.toml
	cp ~/.skhdrc ./skhdrc
	cp ~/.tmux.conf ./tmux.conf
	cp ~/.zshenv ./zshenv
	cp ~/.zshrc ./zshrc
