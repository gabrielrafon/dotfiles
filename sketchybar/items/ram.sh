#!/bin/bash

sketchybar --add item ram right \
  --set ram icon="" icon.font="Symbols Nerd Font:Regular:14.0" \
  label="…" update_freq=2 script="$PLUGIN_DIR/ram.sh" \
  click_script="open -a 'Activity Monitor'" \
  --subscribe ram system_woke
