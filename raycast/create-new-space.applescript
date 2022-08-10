#!/usr/bin/osascript

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Create New Space
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🖥️

# Documentation:
# @raycast.description Creates a new mission control space
# @raycast.author Kelvin Stinghen
# @raycast.authorURL https://github.com/kelvinst

tell application "System Events"
  do shell script "/System/Applications/Mission\\ Control.app/Contents/MacOS/Mission\\ Control"
  click button 1 of group "Spaces Bar" of group 1 of group "Mission Control" of process "Dock"
  do shell script "/System/Applications/Mission\\ Control.app/Contents/MacOS/Mission\\ Control"
end tell
