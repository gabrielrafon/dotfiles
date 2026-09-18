#!/bin/bash

sketchybar --add item network right \
  --set network icon="􀆪" icon.font="SF Pro:Regular:14.0" \
  label="Network…" label.max_chars=24 \
  update_freq=10 script="$PLUGIN_DIR/network.sh" \
  click_script="open 'x-apple.systempreferences:com.apple.Network-Settings.extension'" \
  --subscribe network wifi_change system_woke
