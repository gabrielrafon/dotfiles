#!/bin/bash

bundle="$HOME/.cache/sketchybar/NetworkStatus.app"
cache="$HOME/.cache/sketchybar/network.json"
if [ -d "$bundle" ]; then
  open -g "$bundle"
fi

label="Network…"
color=0xffaaaaaa
icon="􀆪"
font="SF Pro:Regular:14.0"
if [ -f "$cache" ]; then
  # Ignore stale readings after sleep or if the helper stops.
  if jq -e --argjson now "$(date +%s)" '.updatedAt > ($now - 45)' "$cache" >/dev/null 2>&1; then
    label=$(jq -r '.label' "$cache")
    if [ "$(jq -r '.kind' "$cache")" = ethernet ]; then
      icon="󰈀"
      font="Symbols Nerd Font:Regular:14.0"
    fi
    if [ "$(jq -r '.connected' "$cache")" = true ]; then
      color=0xffffffff
    fi
  fi
fi
sketchybar --set "${NAME:-network}" "label=$label" "icon=$icon" "icon.font=$font" "icon.color=$color" "label.color=$color"
