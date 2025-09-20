# NOTE: This file is loaded for all zsh invocations, including non-interactive ones.
# So whatever you need for headless zsh, put it here. e.g. skhd keyboard shortcuts

# Returns the index of the current space
current_space() {
  yabai -m query --spaces --space | jq -r '.index'
}

# Returns the index of the first space in the current display
first_space_from_display() {
  yabai -m query --spaces --display | jq -r 'map(.index) | min'
}

# Returns the index of the last space in the current display
last_space_from_display() {
  yabai -m query --spaces --display | jq -r 'map(.index) | max'
}

# Returns the id of the current window
current_window_id() {
  yabai -m query --windows --window | jq -r '.id'
}

# Focus next space (limiting per display)
focus_next_space() {
  next=$(( $(current_space) + 1 ))

  if [ "$next" -le $(last_space_from_display) ]; then
    yabai -m space --focus "${next}"
  fi
}

# Focus previous space (limiting per display)
focus_previous_space() {
  previous=$(( $(current_space) - 1 ))

  if [ "$previous" -ge $(first_space_from_display) ]; then
    yabai -m space --focus "${previous}"
  fi
}

# Move current window to next space (limiting per display)
move_window_to_next_space() {
  next=$(( $(current_space) + 1 ))
  window_id=$(current_window_id)

  if [ "$next" -le $(last_space_from_display) ]; then
    yabai -m window --space "${next}"
    yabai -m window --focus "${window_id}"
  fi
}

# Move current window to previous space (limiting per display)
move_window_to_previous_space() {
  previous=$(( $(current_space) - 1 ))
  window_id=$(current_window_id)

  if [ "$previous" -ge $(first_space_from_display) ]; then
    yabai -m window --space "${previous}"
    yabai -m window --focus "${window_id}"
  fi
}

# Create a new space and focus it
create_space() {
  yabai -m space --create
  index="$(yabai -m query --spaces --display | jq -r 'map(select(."is-native-fullscreen" == false))[-1].index')"
  yabai -m space --focus "${index}"
}

# Create a new space and move the current window to it
create_space_and_move_window() {
  yabai -m space --create
  index="$(yabai -m query --spaces --display | jq -r 'map(select(."is-native-fullscreen" == false))[-1].index')"
  yabai -m window --space "${index}"
  yabai -m space --focus "${index}"
}

# Move current window to a display
move_window_to_display() {
  window_id=$(current_window_id)
  yabai -m window --display "$1"
  yabai -m window --focus "${window_id}"
}

# Force a determined split type for the current window
force_split_type() {
    split_type=$(yabai -m query --windows --window | jq -r '."split-type"')

    if [ "$split_type" != "$1" ]; then
      yabai -m window --toggle split
    fi
}

# Build 3 column layout for current space
three_column_layout() {
  # Disable focus-follows-mouse for the duration of this function
  yabai -m config focus_follows_mouse off

  # Reset the layout, we need to start from a clean state
  yabai -m config --space $(current_space) layout bsp

  windows_count=$(yabai -m query --windows --space | jq -r 'map(select(."is-visible")) | length')
  window_id=$(current_window_id)

  # If there are less than 3 windows, just put the main window on the last position
  # which is the right in my case. And then we can stop
  if [ "$windows_count" -lt 3 ]; then
    yabai -m window --swap last
    return
  fi

  # Move all windows to the right column except for 3 (2 from the left + 
  # 1 that's already there)
  i=$windows_count
  while [ "$i" -gt 3 ]; do
    # Always skip the first window, it's going to become the main one
    yabai -m window --focus next

    # Send it to the end (right column)
    yabai -m window --warp last

    # Guarantee all windows in the right are split horizontally
    force_split_type horizontal

    # Go back to the first (main) window
    yabai -m window --focus first
    i=$((i - 1))
  done

  # Now this is the magic part, down here we should already have 2 windows in the left +
  # all the others in the right column. So we just ensure the 2 windows in the left are split
  # vertically...
  force_split_type vertical

  # and then we put the first window (main) in the middle column
  yabai -m window --swap next

  # Then we calculate how many windows we need to move from the right column to the
  # left one. Which would always be half of them (discarding the 2 that are not in that column)
  windows_to_move_left=0
  if [ "$windows_count" -gt 3 ]; then
    windows_to_move_left=$(((windows_count - 2) / 2))
  fi

  # We move them all...
  while [ "$windows_to_move_left" -gt 0 ]; do
    yabai -m window --focus last
    yabai -m window --warp first

    # Garanteeing they are split horizontally
    force_split_type horizontal

    windows_to_move_left=$((windows_to_move_left - 1))
  done

  # And finally we balance everything and focus back the main window
  yabai -m space --balance
  yabai -m window --focus "${window_id}"

  # And after all that, we can turn focus-follows-mouse back on
  yabai -m config focus_follows_mouse autofocus
}
