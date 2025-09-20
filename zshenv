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

# Integer division rounding up instead of down
ceil_div() {
  echo $(( ($1 + $2 - 1) / $2 ))
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
  yabai -m config --space $(current_space) layout bsp

  windows_count=$(yabai -m query --windows --space | jq -r 'map(select(."is-visible")) | length')
  window_id=$(current_window_id)

  if [ "$windows_count" -lt 3 ]; then
    yabai -m window --swap last
    return
  fi

  i=$windows_count
  while [ "$i" -gt 3 ]; do
    yabai -m window --focus next
    yabai -m window --warp last

    force_split_type horizontal

    yabai -m window --focus first
    i=$((i - 1))
  done

  yabai -m window --toggle split
  yabai -m window --swap next

  windows_to_move_left=0

  if [ "$windows_count" -gt 3 ]; then
    windows_to_move_left=$(ceil_div $((windows_count - 3)) 2)
  fi

  echo "Total windows: $windows_count"
  echo "Moving $windows_to_move_left windows to the left column"

  while [ "$windows_to_move_left" -gt 0 ]; do
    yabai -m window --focus last
    yabai -m window --warp first

    force_split_type horizontal

    windows_to_move_left=$((windows_to_move_left - 1))
  done

  yabai -m space --balance
  yabai -m window --focus "${window_id}"
}
