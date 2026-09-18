#!/bin/bash

# Read the text of Notion's native status item through the local AX helper.
sketchybar --add item "Notion Calendar" left \
  --set "Notion Calendar" update_freq=10 updates=on drawing=off \
  icon="▏" icon.font="Helvetica:Bold:14.0" \
  label.font="Helvetica:Regular:13.0" \
  padding_left=5 padding_right=5 \
  script="$PLUGIN_DIR/current_event.sh" \
  click_script="open -a 'Notion Calendar'"
