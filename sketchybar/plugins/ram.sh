#!/bin/bash

total=$(/usr/sbin/sysctl -n hw.memsize) || exit 0
stats=$(/usr/bin/vm_stat) || exit 0

# Physical memory in use: anonymous + wired + compressed, less purgeable pages.
# Excludes file cache and swap, and reads the actual page size (Intel/Apple Silicon).
label=$(printf '%s\n' "$stats" | awk -F ': *' -v total="$total" '
  /page size of/ {
    header=$0
    sub(/^.*page size of /, "", header)
    page_size=header+0
  }
  /^Anonymous pages:/ { anonymous=$2+0; have_anonymous=1 }
  /^Pages wired down:/ { wired=$2+0; have_wired=1 }
  /^Pages occupied by compressor:/ { compressed=$2+0; have_compressed=1 }
  /^Pages purgeable:/ { purgeable=$2+0 }
  END {
    if (total <= 0 || page_size <= 0 || !have_anonymous || !have_wired || !have_compressed) {
      print "?"
      exit
    }
    used=(anonymous+wired+compressed-purgeable)*page_size
    if (used < 0) used=0
    if (used > total) used=total
    printf "%.0f%%", 100*used/total
  }
')

sketchybar --set "${NAME:-ram}" "label=$label"
