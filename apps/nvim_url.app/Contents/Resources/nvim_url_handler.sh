#!/bin/bash

# Outptu all output to a log file for debugging
exec >> /tmp/nvim_url_handler.log 2>&1

PATH="/Applications/kitty.app/Contents/MacOS:/opt/homebrew/bin:$PATH"

# List all kitty sockets that are not quick-access and have windows
list_kitty_sockets() {
  quick_access_pid=$(pgrep -x kitty-quick-access)

  for s in /tmp/kitty-*; do
    [[ -n "$quick_access_pid" && "$s" == *"$quick_access_pid"* ]] && continue

    echo $s
  done
}

# List all windows in a kitty instance
list_kitty_windows() {
  if [ -z "$1" ]; then
    for s in $(list_kitty_sockets); do
      list_kitty_windows "$s" | 
        jq -r --arg kitty_socket "$s" 'map(. + {socket: $kitty_socket})'
    done | jq -s 'add'
  else
    kitten @ ls --to "unix:$1" 2>/dev/null | 
      jq -r '
        map(.tabs) | flatten | 
          map(.windows) | flatten | 
          map({
            id: .id, 
            cwd: .cwd, 
            fg_cmdlines: .foreground_processes | map(.cmdline | join(" "))
          })
        '
  fi
}

# Returns the "best" kitty socket to start the new vim tab in
best_kitty_socket() {
  list_kitty_windows | jq -r --arg file $1 '
    # Sort by the longest cwds first
    sort_by(.cwd | length) | reverse |

    # Save all windows
    . as $all |
    
    # Find matching windows
    map(
      . as $window |
      select(
        ($file | startswith($window.cwd + "/")) or ($file == .cwd)
      )
    ) |

    # Return the first one (the longest match)
    (if length > 0 then
      first
    else
      $all | first
    end) |
    .socket
  '

}

focus_nvim_window() {
  nvim_window=$(list_kitty_windows | jq -r --arg nvim_socket "$1" '
    map({socket, id, fg_cmdline: .fg_cmdlines[]}) |
      map(select(
        (.fg_cmdline | startswith("nvim")) and 
          (.fg_cmdline | contains("--listen " + $nvim_socket)))
      ))
  ')

  kitten @ focus-window --to "unix:$(jq -r '.socket' <<< $nvim_window)" --window-id "$(jq -r '.id' <<< $nvim_window)" 2>/dev/null
}

# This script is intended to be used as a URL handler for nvim:// URLs.
#
# Example URL: 
#   nvim://file/~/.zshrc:40
full="$1"

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

    nvim --server "$nvim_socket" --remote-tab "$file"
    nvim --server "$nvim_socket" --remote-send "${line}G"

    focus_nvim_window $nvim_socket

    exit 0
  fi

  kitty_socket=$(best_kitty_socket "$file")

  # If kitty socket found, open a new tab in that instance
  if [ -n "$kitty_socket" ]; then
    echo "Adding new tab to existing kitty instance at socket: $kitty_socket"

    wid=$(kitten @ launch --to="unix:$kitty_socket" --copy-env --type=tab nvim +"${line}" "$file")

    kitten @ focus-window --to="unix:$kitty_socket" --match=id:"$wid"

    exit 0
  fi

  # Final fallback: open a new kitty instance
  echo "No existing kitty instance found, opening a new one"

  kitty --single-instance nvim +"${line}" "$file"
fi
