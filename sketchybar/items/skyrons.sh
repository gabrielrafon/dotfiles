#!/bin/bash

sketchybar --add item skyrons.logo right \
  --set skyrons.logo width=dynamic \
  padding_left=5 padding_right=5 \
  icon="" icon.drawing=on icon.width=14 icon.align=center \
  icon.padding_left=0 icon.padding_right=0 \
  label.drawing=off \
  background.color=0x00000000 \
  icon.background.drawing=on \
  icon.background.color=0x00000000 \
  icon.background.height=14 \
  icon.background.image="$CONFIG_DIR/assets/skyrons.png" \
  icon.background.image.scale=0.39
