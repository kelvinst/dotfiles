# clear
alias c='clear'

# git
alias g='git status -sb'
alias ga='git add --verbose'
alias gc='git commit --verbose'
alias gco='git checkout'
alias gd='git diff'
alias gl='git log --oneline --decorate --graph'
alias gp='git push'
alias gpsup="git push --set-upstream origin \$(git_current_branch)"
alias gpf='git push --force-with-lease --force-if-includes'
alias gr='git reset'
alias gu='git pull'

# lazygit
alias lazygit='tmux setw monitor-activity off && lazygit'
alias lg='lazygit'

# ls
alias l='ls -Gla'

# make
alias m='make'

# tmux
alias t='tmux'

# vim/nvim
alias v='nvim'

# zsh
alias z='source ~/.zshrc'

# Remove some useless predefined aliases
unalias -m run-help
unalias -m which-command

