#!/bin/bash

# Outptu all output to a log file for debugging
exec >> /tmp/nvim_url_handler.log 2>&1

# List all kitty sockets that are not quick-access and have windows
list_kitty_sockets() {
  quick_access_pid=$(pgrep -x kitty-quick-access)

  for s in /tmp/kitty-*; do
    if [[ -n "$quick_access_pid" && "$s" == *"$quick_access_pid"* ]]; then
      continue
    fi

    out=$(kitten @ --to "unix:$s" ls 2>/dev/null)
    if [[ -n "$out" && "$out" != "[]" ]]; then
      echo $s
    fi
  done
}

# This script is intended to be used as a URL handler for nvim:// URLs.
#
# Example URL: 
#   nvim://file/~/.zshrc:40
full="$1"

PATH="/Applications/kitty.app/Contents/MacOS:/opt/homebrew/bin:$PATH"

if [ -n "$full" ]; then
  # URL-decode if needed (keeps working even if python3 is missing)
  urldecode() {
    local data="${1//+/ }"   # convert + to space
    printf '%b' "${data//%/\\x}"
  }
  full_decoded=$(urldecode "$full")

  # Split file and line
  file="${full_decoded%%:*}"
  line="${full_decoded##*:}"

  # Expand leading "~" to $HOME (tilde won't expand in quotes)
  if [[ "$file" == "~"* ]]; then
    file="${file/#\~/$HOME}"
  fi

  # Find an existing nvim socket
  nvim_socket=$(ls /tmp/nvim-* 2>/dev/null | sort | head -n 1 || true)

  # If nvim socket found, open a new tab in that instance
  if [ -n "$nvim_socket" ]; then
    echo "Adding new tab to existing nvim instance at socket: $nvim_socket"
    echo "  Commands:"
    echo "    nvim --server $nvim_socket --remote-tab $file"
    echo "    nvim --server $nvim_socket --remote-send \"${line}G\""

    nvim --server "$nvim_socket" --remote-tab "$file"
    nvim --server "$nvim_socket" --remote-send "${line}G"
    exit 0
  fi

  kitty_socket=$(list_kitty_sockets | sort | head -n 1 || true)

  # If kitty socket found, open a new tab in that instance
  if [ -n "$kitty_socket" ]; then
    echo "Adding new tab to existing kitty instance at socket: $kitty_socket"
    echo "  Command: kitten @ --to unix:$kitty_socket --copy-env --type=tab nvim +${line} $file"

    kitten @ launch --to "unix:$kitty_socket" --copy-env --type=tab nvim +"${line}" "$file"
    exit 0
  fi

  # Final fallback: open a new kitty instance
  echo "No existing kitty instance found, opening a new one"
  echo "  Command: kitty nvim +${line} $file"

  kitty --single-instance nvim +"${line}" "$file"
fi
