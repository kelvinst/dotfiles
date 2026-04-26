.PHONY: clean install
all: clean install

install:
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
	mkdir -p ~/.config/sketchybar/
	cp -r ./config/sketchybar/* ~/.config/sketchybar/
	mkdir -p ~/.config/sketchybar_bash/
	cp -r ./config/sketchybar_bash/* ~/.config/sketchybar_bash/
	cd ~/.config/sketchybar/helpers/menus && make
	find ~/.config/sketchybar -type f -name "*.sh" -exec chmod +x {} \;
	find ~/.config/sketchybar_bash -type f \( -name "*.sh" -o -name "sketchybarrc" \) -exec chmod +x {} \;
	mkdir -p ~/.hammerspoon/
	cp -r ./hammerspoon/* ~/.hammerspoon/
	mkdir -p ~/.local/bin/
	cp -r ./bin/* ~/.local/bin/
	for f in ./bin/*; do chmod -R +x ~/.local/bin/$$(basename $$f); done
	mkdir -p ~/.zsh/completions/
	cp -r ./zsh/completions/* ~/.zsh/completions/
	cp -r ./config/init_starship.sh ~/.config/
	cp -r ./config/starship.toml ~/.config/
	cp -r ./config/starship-full.toml ~/.config/
	cp ./aerospace.toml ~/.aerospace.toml
	cp ./ai-jail ~/.ai-jail
	cp ./default-gems ~/.default-gems
	cp ./gitconfig ~/.gitconfig
	cp ./global_gitignore ~/.global_gitignore
	cp ./paneru.toml ~/.paneru.toml
	cp ./skhdrc ~/.skhdrc
	cp ./tmux.conf ~/.tmux.conf
	cp ./zshenv ~/.zshenv
	cp ./zshrc ~/.zshrc

clean:
	rm -rf ~/.config/direnv/*
	rm -rf ~/.config/kitty/*
	rm -rf ~/.config/nvim/*
	rm -rf ~/.config/tms/*
	rm -rf ~/.config/tidewave/*
	rm -rf ~/.config/sketchybar/*
	rm -rf ~/.config/sketchybar_bash/*
	rm -rf ~/.hammerspoon/*
	for f in ./bin/*; do rm -rf ~/.local/bin/$$(basename $$f); done
	rm -rf ~/.config/init_starship.sh
	rm -rf ~/.config/starship.toml
	rm -rf ~/.config/starship-full.toml
	rm -rf ~/.aerospace.toml
	rm -rf ~/.ai-jail
	rm -rf ~/.default-gems
	rm -rf ~/.gitconfig
	rm -rf ~/.global_gitignore
	rm -rf ~/.paneru.toml
	rm -rf ~/.skhdrc
	rm -rf ~/.tmux.conf
	rm -rf ~/.zshenv
	rm -rf ~/.zshrc

update:
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
	mkdir -p ./config/sketchybar/
	cp -r ~/.config/sketchybar/* ./config/sketchybar/
	mkdir -p ./hammerspoon
	mkdir -p ./zsh/completions/
	cp -r ~/.zsh/completions/* ./zsh/completions/
	cp -r ~/.config/init_starship.sh ./config/
	cp -r ~/.config/starship.toml ./config/
	cp -r ~/.config/starship-full.toml ./config/
	cp -r ~/.hammerspoon/* ./hammerspoon/
	mkdir -p ./bin/
	for f in ./bin/*; do cp -r ~/.local/bin/$$(basename $$f) ./bin/; done
	cp ~/.aerospace.toml ./aerospace.toml
	cp ~/.ai-jail ./ai-jail
	cp ~/.default-gems ./default-gems
	cp ~/.gitconfig ./gitconfig
	cp ~/.global_gitignore ./global_gitignore
	cp ~/.paneru.toml ./paneru.toml
	cp ~/.skhdrc ./skhdrc
	cp ~/.tmux.conf ./tmux.conf
	cp ~/.zshenv ./zshenv
	cp ~/.zshrc ./zshrc
