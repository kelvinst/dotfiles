.PHONY: backup clean install update
.DEFAULT_GOAL := install

BACKUP_ROOT := $(HOME)/.dotfiles-backups

# Every path install writes to, relative to $HOME. Directories listed here are
# owned wholesale by this repo; individual files are listed one by one so we
# never touch neighbouring state (e.g. the rest of ~/.claude, ~/.local/bin).
HOME_TARGETS := \
	.aerospace.toml \
	.ai-jail \
	.claude/settings.json \
	.config/direnv \
	.config/init_starship.sh \
	.config/kitty \
	.config/nvim \
	.config/starship-full.toml \
	.config/starship.toml \
	.config/tidewave \
	.config/tms \
	.default-gems \
	.gitconfig \
	.global_gitignore \
	.hammerspoon \
	.paneru.toml \
	.skhdrc \
	.tmux.conf \
	.zsh/completions \
	.zshenv \
	.zshrc

BIN_TARGETS := $(patsubst bin/%,.local/bin/%,$(wildcard bin/*))
HOOK_TARGETS := $(patsubst claude/hooks/%,.claude/hooks/%,$(wildcard claude/hooks/*))

ALL_TARGETS := $(HOME_TARGETS) $(BIN_TARGETS) $(HOOK_TARGETS)

# Move every installed path into a timestamped backup folder. This doubles as
# the "remove the old copy" step, so install always lands on a clean slate
# without silently destroying whatever was there.
backup:
	@stamp=$$(date +%Y%m%d-%H%M%S); \
	dest="$(BACKUP_ROOT)/$$stamp"; \
	saved=0; \
	for p in $(ALL_TARGETS); do \
		src="$(HOME)/$$p"; \
		if [ -e "$$src" ] || [ -L "$$src" ]; then \
			mkdir -p "$$dest/$$(dirname "$$p")" || exit 1; \
			mv -f "$$src" "$$dest/$$p" || exit 1; \
			saved=$$((saved + 1)); \
		fi; \
	done; \
	if [ $$saved -gt 0 ]; then \
		echo "backed up $$saved path(s) to $$dest"; \
	else \
		echo "nothing installed yet, skipping backup"; \
	fi

install: backup
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
	mkdir -p ~/.local/bin/
	cp -r ./bin/* ~/.local/bin/
	for f in ./bin/*; do chmod -R +x ~/.local/bin/$$(basename $$f); done
	mkdir -p ~/.claude/hooks/
	cp -f ./claude/hooks/* ~/.claude/hooks/
	chmod +x ~/.claude/hooks/*
	cp -f ./claude/settings.json ~/.claude/settings.json
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
	for s in /tmp/kitty-*; do [ -S "$$s" ] && kitty @ --to unix:$$s load-config || true; done

clean:
	rm -rf ~/.config/direnv/*
	rm -rf ~/.config/kitty/*
	rm -rf ~/.config/nvim/*
	rm -rf ~/.config/tms/*
	rm -rf ~/.config/tidewave/*
	rm -rf ~/.hammerspoon/*
	for f in ./bin/*; do rm -rf ~/.local/bin/$$(basename $$f); done
	for f in ./claude/hooks/*; do rm -f ~/.claude/hooks/$$(basename $$f); done
	rm -f ~/.claude/settings.json
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
	mkdir -p ./hammerspoon
	mkdir -p ./zsh/completions/
	cp -r ~/.zsh/completions/* ./zsh/completions/
	cp -r ~/.config/init_starship.sh ./config/
	cp -r ~/.config/starship.toml ./config/
	cp -r ~/.config/starship-full.toml ./config/
	cp -r ~/.hammerspoon/* ./hammerspoon/
	mkdir -p ./bin/
	for f in ./bin/*; do cp -r ~/.local/bin/$$(basename $$f) ./bin/; done
	mkdir -p ./claude/hooks/
	cp -f ~/.claude/hooks/* ./claude/hooks/
	cp -f ~/.claude/settings.json ./claude/settings.json
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
