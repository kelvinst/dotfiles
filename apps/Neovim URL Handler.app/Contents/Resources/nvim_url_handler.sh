#!/bin/bash

# Outptu all output to a log file for debugging
exec >> /tmp/nvim_url_handler.log 2>&1

# This script is intended to be used as a URL handler for nvim:// URLs.
#
# Example URL: 
#   nvim://file/~/.zshrc:40
full="$1"

PATH="/Applications/kitty.app/Contents/MacOS:/opt/homebrew/bin:$PATH"

if [ -n "$full" ]; then
  # 1) URL-decode if needed (keeps working even if python3 is missing)
  urldecode() {
    local data="${1//+/ }"   # convert + to space
    printf '%b' "${data//%/\\x}"
  }
  full_decoded=$(urldecode "$full")

  # 2) Split file and line
  file="${full_decoded%%:*}"
  line="${full_decoded##*:}"

  # 3) Expand leading "~" to $HOME (tilde won't expand in quotes)
  if [[ "$file" == "~"* ]]; then
    file="${file/#\~/$HOME}"
  fi

  # 4) Find an existing kitty socket with windows, that's not quick-access
  quick_access_pid=$(pgrep -x kitty-quick-access)
  socket=""
  for s in /tmp/kitty-*; do
    if [[ "$s" == *"$quick_access_pid"* ]]; then
      continue
    fi
    
    out=$(kitten @ --to "unix:$s" ls 2>/dev/null)
    if [[ -n "$out" && "$out" != "[]" ]]; then
      socket=$s
      break
    fi
  done

  if [ -n "$socket" ]; then
    echo "Adding new tab to existing kitty instance at socket: $socket"
    echo "  Command: kitten @ --to unix:$socket --copy-env --type=tab nvim +${line} $file"
    # 5) Open a new tab in the existing kitty instance and run nvim with the provided file path
    kitten @ launch --to "unix:$socket" --copy-env --type=tab nvim +"${line}" "$file"
  else
    echo "No existing kitty instance found, opening a new one"
    echo "  Command: kitty nvim +${line} $file"
    # 5) Open a new kitty instance and run nvim with the provided file path
    kitty nvim +"${line}" "$file"
  fi
fi
