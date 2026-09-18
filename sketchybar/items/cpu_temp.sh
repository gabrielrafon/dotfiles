#!/bin/bash

sketchybar --add item cpu_temp right \
  --set cpu_temp icon="" icon.font="Symbols Nerd Font:Regular:14.0" \
  label="…" update_freq=5 script="$PLUGIN_DIR/cpu_temp.sh" \
  --subscribe cpu_temp system_woke
