#!/bin/bash
set -euo pipefail
helper_dir=$(cd "$(dirname "$0")" && pwd)
cache="$HOME/.cache/sketchybar"
mkdir -p "$cache"
clang -O2 -Wall -Wextra -mmacosx-version-min=13.0 \
  "$helper_dir/cpu-temperature.c" -framework CoreFoundation -framework IOKit \
  -o "$cache/cpu-temperature"
