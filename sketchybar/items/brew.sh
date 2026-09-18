#!/bin/bash

sketchybar --add event brew_update \
  --add item brew right \
  --set brew icon="􀐛" label="…" update_freq=1800 \
  script="$PLUGIN_DIR/brew.sh" \
  click_script="$PLUGIN_DIR/brew.sh" \
  --subscribe brew brew_update system_woke
