#!/bin/bash

sketchybar --add event aerospace_workspace_change

for sid in {1..10}; do
  sketchybar --add item space.$sid left \
    --set space.$sid \
    drawing=off \
    background.color=0x44ffffff \
    background.corner_radius=5 \
    background.height=20 \
    background.drawing=off \
    label.y_offset=-1 \
    label.font="sketchybar-app-font:Regular:14.0" \
    label.padding_right=5 \
    icon=$sid \
    click_script="aerospace workspace $sid"
done

# One update for every workspace, including window moves that do not change focus.
sketchybar --add item aerospace.observer left \
  --set aerospace.observer drawing=off updates=on update_freq=5 \
  script="$PLUGIN_DIR/aerospace.sh" \
  --subscribe aerospace.observer aerospace_workspace_change front_app_switched system_woke
