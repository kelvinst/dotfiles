#!/bin/bash

# This script is intended to be used as a URL handler for nvim:// URLs.
#
# Example URL: 
#   nvim://file/~/.zshrc:40
full="$1"

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

# 4) Open a new instance of kitty and run nvim with the provided file path
/Applications/kitty.app/Contents/MacOS/kitty /opt/homebrew/bin/nvim +"${line}" "$file"

