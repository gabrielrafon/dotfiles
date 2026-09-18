#!/bin/bash

source "$CONFIG_DIR/plugins/icon_map_fn.sh" --source-only

focused=$(aerospace list-workspaces --focused) || exit 0
windows=$(aerospace list-windows --all --format '%{workspace}|%{app-name}') || exit 0
# Workspace items 1–10 are created on reload and shown only when needed.
spaces=$(sketchybar --query bar | jq -r '.items[] | select(startswith("space."))') || exit 0
args=()
while IFS= read -r item; do
  sid=${item#space.}
  apps=$(printf '%s\n' "$windows" | awk -F '|' -v sid="$sid" '$1 == sid {sub(/^[^|]*\|/, ""); print}' | LC_ALL=C sort -u)
  icons=""
  while IFS= read -r app; do
    [ -n "$app" ] || continue
    icon_map "$app"
    icons="${icons:+$icons }$icon_result"
  done <<< "$apps"
  selected=off
  [ "$sid" = "$focused" ] && selected=on
  visible=off
  if [ -n "$apps" ] || [ "$selected" = on ]; then
    visible=on
  fi
  args+=(--set "$item" "drawing=$visible" "label=$icons" "background.drawing=$selected")
done <<< "$spaces"
[ ${#args[@]} -gt 0 ] && sketchybar "${args[@]}"
