#!/bin/bash

# Use the same thermal sensor groups as btop on Apple Silicon.
label="—"
if temperature=$("$HOME/.cache/sketchybar/cpu-temperature" 2>/dev/null); then
  label=$(awk -v temperature="$temperature" 'BEGIN {printf "%.0f°C", temperature}')
fi

sketchybar --set "${NAME:-cpu_temp}" "label=$label"
