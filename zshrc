# NOTE: Env variables {{{

# My preferred editor
export EDITOR='nvim'

# URL scheme for opening files in nvim from other applications
export PLUG_EDITOR="nvim://file/__FILE__:__LINE__"

# Add local bin to the beginning of PATH
export PATH="$HOME/.local/bin:$PATH"

# Add homebrew bins to the beginning of PATH
export PATH="/opt/homebrew/bin:$PATH"

# Add rust bin to path
export PATH="$(asdf where rust)/bin:$PATH"

# Add opencode bin to path
export PATH="$HOME/.opencode/bin:$PATH"

# Setting tmux-sessionizer config path
export TMS_CONFIG_FILE="$HOME/.config/tms/config.toml"

# Default configs dir
export XDG_CONFIG_HOME="$HOME/.config"

# Coloring files
export LS_COLORS="$(vivid generate tokyonight-moon)"

# }}}

# NOTE: Completions {{{

# Configure additional completion definitions
export FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/kelvinstinghen/.docker/completions $fpath)

# Load the completion system
autoload -Uz compinit
compinit

# Command prompt formatter starship
eval "$(starship completions zsh)"

# Suggest commands as you type
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load the amazing tab completion fuzzy finder
source ~/.fzf-tab/fzf-tab.plugin.zsh
source ~/.fzf-tab-source/*.plugin.zsh

# All these are configurations for the fuzzy finder completion tool
# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# Set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# Set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# Force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# Preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
# Preview for many git subcommands
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'case "$group" in "commit tag") git show --color=always $word ;; *) git show --color=always $word | delta ;; esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'case "$group" in "modified file") git diff $word | delta ;; "recent commit object name") git show --color=always $word | delta ;; *) git log --color=always $word ;; esac'
# Space to accept the selection
zstyle ':fzf-tab:*' fzf-flags --bind=space:accept
# Switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# }}}

# NOTE: General shell improvements {{{

# Syntax highlightning for the shell commands
source ~/.fsyh/fast-syntax-highlighting.plugin.zsh

# `z` - the fuzzy `cd`
eval "$(zoxide init zsh)"

# Use shell vim mode
bindkey -v

# }}}

# NOTE: Dev stuff {{{

# The runtime version manager
. /opt/homebrew/opt/asdf/libexec/asdf.sh

# }}}

# NOTE: Aliases {{{

# alias
alias a='aliases'

# bat
alias b='bat'

# clear
alias bp='bottom_prompt'
alias c='clear'

# eza
alias ez='eza'
alias e='eza -Gla'

# git
alias g='git'
alias gg='git status -sb'
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
alias lg='lazygit'

# ls
alias ls='gls'
alias lc='ls --color'
alias l='lc --color -Gla'

# make
alias m='make'

# source
alias s='source'
alias sz='source ~/.zshrc && source ~/.zshenv'

# tmux
alias t='tmux'

# vim/nvim
alias nvim='nvim --listen /tmp/nvim-$(date +%s%N)'
alias v='nvim'

# Remove some useless predefined aliases
unalias -m run-help
unalias -m which-command

# }}}

# NOTE: Functions {{{

# Searches for aliases
aliases() {
  if [[ -z $1 ]]; then
    alias
  else
    alias | rg $1
  fi
}

# Shows `git status -sb` if no arguments are given, otherwise runs `git` with the provided arguments
git() {
  if [[ $# -eq 0 ]]; then
    command git status -sb
  else
    command git "$@"
  fi
}

# Returns the current git branch
git_current_branch() {
  git rev-parse --abbrev-ref HEAD 2>/dev/null
}

# Retries a command until it fails
flaky() {
  local attempt=1
  local temp_file=$(mktemp)

  # Define color codes
  local green="\033[32m"
  local reset="\033[0m"

  echo -e "Running flaky command: ${green}$*${reset}"

  while true; do
    printf "\rAttempt ${green}#$attempt${reset}..."

    # Use 'script' to capture colored output
    if ! script -q $temp_file $* > /dev/null 2>&1; then
      echo
      printf "\nFailed command output:\n"
      cat "$temp_file"
      rm -f "$temp_file"
      break
    fi
    attempt=$((attempt + 1))
  done
}

# Functions to enable/disable command info
disable_cmd_info() { export DISABLE_CMD_INFO=1 }
enable_cmd_info() { unset DISABLE_CMD_INFO }

# Add empty lines to move the prompt to the bottom of the terminal
bottom_prompt() {
  local offset=${1:-1}
  local filename="/tmp/kitty-output-$(date +%s)"

  # Save terminal output to a temp file
  kitten @ get-text --extent=all --ansi=yes --self=yes > $filename

  # Get the number of lines in the output
  local output_lines=$(wc -l < $filename)

  # If the output is smaller than $LINES - 1, add newlines to the file
  if [[ $output_lines -lt ($LINES - $offset) ]]; then
    # Add newlines to the beginning of the file until we reach the bottom
    while [[ $output_lines -lt ($LINES - $offset) ]]; do
      sed -i '' '1i\

        ' $filename
      output_lines=$((output_lines + 1))
    done

    clear
    cat $filename
  fi

  rm -rf /tmp/kitty-output-*
}

# }}}

# NOTE: Auto-commands {{{

# Put the prompt at the bottom on shell startup
bottom_prompt 2

# Load add-zsh-hook for managing hooks
autoload -Uz add-zsh-hook

# Ring a bell on command failures
bell_on_error() {
  if [[ $? -ne 0 ]]; then
    printf "\a"
  fi
}
add-zsh-hook precmd bell_on_error

# Color codes
local gray=$'\e[37m' 
local purple=$'\e[35m'
local blue=$'\e[34m'
local bold_red=$'\e[31;1m'
local bold_green=$'\e[32;1m'
local bold_yellow=$'\e[33;1m'  # Bold yellow
local nc=$'\e[0m'

# Global variable to store the last executed command
LAST_CMD=""
LAST_CMD_EXECUTED=0

# Code extracted and adapted from here:
#https://github.com/quicknir/nikud/blob/27f4dd0275730a9f64dae7e37db0ae1097834b2e/zsh/zdotdir/color_history.zsh#L1-L86
highlight_to_format() {
    local parts=(${(s/,/)1})
    local before=""
    local after=""
    for part in $parts; do
        case "$part" in
            underline)
                before+="%U"
                after+="%u"
                ;;
            bold)
                before+="%B"
                after+="%b"
                ;;
            fg*)
                local sub_parts=(${(s/=/)part})
                before+="%F{$sub_parts[2]}"
                after+="%f"
                ;;
            bg*)
                local sub_parts=(${(s/=/)part})
                before+="%K{$sub_parts[2]}"
                after+="%k"
                ;;
        esac
    done
    pre_escape=${(%)before}
    post_escape=${(%)after}
}

apply_format_to_substr() {
    local mapped_first=$index_map[$first]
    local mapped_last=$index_map[$last]
    s=$1
    local insert_string=${pre_escape}${s[$mapped_first,$mapped_last]}${post_escape}
    s[$mapped_first,$mapped_last]=$insert_string
}

highlight_to_str() {
    local str=$1
    local highlight_arr_name=$2
    local -A index_map
    local str_length=${#str}
    local i pre_escape post_escape s v

    for i in {1..${#str}}; do index_map[$i]=$i; done

    for highlight in ${(P)${highlight_arr_name}}; do
        local parts=(${(s/ /)highlight})

        if [[ ${#parts} != 3 ]]; then 
            # Sometimes we get bad responses from fast-syntax highlighting
            # e.g. if fed '($index++)', we get
            # 0 1 fg=yellow 1 9 fg=red,bold 9 10 fg=yellow 0 1 fg=green,bold 9 10 fg=green,bold 9 10 bg=blue  1 bg=blue
            # That trailing style doesn't have a begin and end; so we just ignore it
            continue
        fi

        local first=$((parts[1]+1))
        local last=$parts[2]

        if [[ $first -gt $last ]]; then
            # Again, fast-syntax sometimes includes segments like this where start is greater than end
            # have observed it with git commit -m <quoted text>
            continue
        fi

        highlight_to_format $parts[3]

        local pre_escape_len=${#pre_escape}
        local post_escape_len=${#post_escape}
        apply_format_to_substr $str
        str=${(%)s}
        for i in {$first..$last}; do
            v=$index_map[$i]
            index_map[$i]=$((v+pre_escape_len))
        done
        if [[ $last != $str_length ]]; then
            for i in {$((last+1))..$str_length}; do
                v=$index_map[$i]
                index_map[$i]=$((v+pre_escape_len+post_escape_len))
            done
        fi
    done
    echo -n $str
}

# Highlight the command using fast-syntax-highlighting
highlight_command() {
  local cmd=$1
  local -a reply
  reply=()
  -fast-highlight-process "" $cmd 0
  -fast-highlight-string-process "" "$1"

  local colored_cmd=$(highlight_to_str $cmd reply)

  colored_cmd="${colored_cmd//\$/\\$}"

  print -Pr -- $colored_cmd
}

# Show alias commands when executing them
print_info_before_cmd() {
  # Sace the last command executed
  LAST_CMD=$1

  if [[ 
    -z $DISABLE_CMD_INFO &&
      $LAST_CMD != *disable_cmd_info* &&
      $LAST_CMD != *enable_cmd_info*
  ]]; then
    # The the command being executed
    local -a words
    words=( ${(z)LAST_CMD} )
    local cmd=${words[1]}

    local cmd_desc=$(whence -v $cmd 2>/dev/null)

    # Remove the "cmd is " or "cmd " prefix
    cmd_desc=${cmd_desc#$cmd }
    cmd="$(highlight_command $cmd)$gray"

    # Apply formatting based on content
    if [[ $cmd_desc == "not found" ]]; then
      cmd_desc="${bold_red}not found"
    elif [[ $cmd_desc =~ "^is an alias for (.+)$" ]]; then
      local alias_target=$(highlight_command ${match[1]})
      cmd_desc="$cmd is an ${blue}alias$nc$gray for $alias_target"
    elif [[ $cmd_desc =~ "^is a shell (builtin|function)$" ]]; then
      cmd_desc="$cmd is a shell ${blue}${match[1]}"
    elif [[ $cmd_desc =~ "^is an autoload shell function$" ]]; then
      cmd_desc="$cmd is an ${blue}autoload$nc$gray shell ${blue}function"
    elif [[ $cmd_desc =~ "^is an autoload shell function from (.+)$" ]]; then
      local path="$purple${match[1]}"
      cmd_desc="$cmd is an ${blue}autoload$nc$gray shell ${blue}function$nc$gray from $path"
    elif [[ $cmd_desc =~ "^is a shell function from (.+)$" ]]; then
      local path="$purple${match[1]}"
      cmd_desc="$cmd is a shell ${blue}function$nc$gray from $path"
    elif [[ $cmd_desc =~ "^is a reserved word$" ]]; then
      cmd_desc="$cmd is a ${blue}reserved$nc$gray word"
    elif [[ $cmd_desc =~ "^is (.+)$" ]]; then
      local executable=$(highlight_command ${match[1]})
      cmd_desc="$cmd is $executable"
    fi

    # Wrap entire description in gray
    cmd_desc="${gray}${cmd_desc}${nc}"
    local last_cmd=$(highlight_command $LAST_CMD)

    # Print the command info
    echo "${gray}┏ running $last_cmd ${gray}(${nc}$cmd_desc${gray})$nc"
  fi

  # Save that a command was executed
  LAST_CMD_EXECUTED=1
}
add-zsh-hook preexec print_info_before_cmd

# Load starship prompt before each prompt render
load_starship_prompt() {
  source $HOME/.config/init_starship.sh
}
load_starship_prompt

# Print info after command execution
print_info_after_cmd() {
  # Save the command status code
  local last_status=$status

  # Reload starship prompt, as it is reset after each cmd execution/interruption
  load_starship_prompt

  if [[ $LAST_CMD_EXECUTED -eq 1 ]]; then
    if [[ 
      -z "$DISABLE_CMD_INFO" &&
        "$LAST_CMD" != *disable_cmd_info* &&
        "$LAST_CMD" != *enable_cmd_info*
    ]]; then
      local last_cmd=$(highlight_command "$LAST_CMD")
      local duration="🕘$bold_yellow ${STARSHIP_DURATION}ms$gray"

      if [[ $last_status -eq 0 ]]; then
        last_status="✅$bold_green $last_status$gray"
      elif [[ $last_status -eq 126 ]]; then
        # Not executable
        last_status="🚫$bold_red $last_status$gray"
      elif [[ $last_status -eq 127 ]]; then
        # Not found
        last_status="❓$bold_red $last_status$gray"
      elif [[ $last_status -ge 128 ]] && [[ $last_status -le 165 ]]; then
        # Signal
        last_status="💥$bold_red $last_status$gray"
      else
        # General failure
       last_status="❗$bold_red $last_status$gray"
      fi

      echo "$gray┗ finished $last_cmd in $duration with $last_status$nc"
    fi

    echo
    unset LAST_CMD
  fi

  unset LAST_CMD_EXECUTED
}
add-zsh-hook precmd print_info_after_cmd

# Clear the prompt on command execution/interruption
clear_prompt() {
  PROMPT=''
  zle .reset-prompt
}
zle -N zle-line-finish clear_prompt
trap 'clear_prompt; return 130' INT

# Keep the prompt at the bottom on terminal resize
TRAPWINCH() {
  bottom_prompt
  zle .reset-prompt
}

# }}}

# NOTE: Load private zshrc if it exists {{{

if [ -f ~/.zshrc_private ]; then
  source ~/.zshrc_private
fi

# }}}


