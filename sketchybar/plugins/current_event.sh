#!/bin/bash

bundle="$HOME/.cache/sketchybar/NotionMirror.app"
cache="$HOME/.cache/sketchybar/notion-mirror.json"
[ -d "$bundle" ] && open -g "$bundle"
if [ -f "$cache" ] && jq -e --argjson now "$(date +%s)" \
  '.state == "ok" and .updatedAt > ($now - 30)' "$cache" >/dev/null 2>&1; then
  title=$(jq -r '.title' "$cache")
  sketchybar --set "${NAME:-Notion Calendar}" drawing=on "label=$title"
else
  sketchybar --set "${NAME:-Notion Calendar}" drawing=off
fi
