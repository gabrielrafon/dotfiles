#!/bin/bash

# Allow Homebrew's normal throttled metadata refresh, outside bar startup.
# Count formulae and casks once each; never interpret errors as zero updates.
# SketchyBar ignores SIGCHLD; reset it before Ruby spawns cask-version helpers.
# Otherwise Homebrew can fail with "undefined method 'exitstatus' for nil".
if outdated=$(/usr/bin/perl -e '$SIG{CHLD}="DEFAULT"; exec @ARGV' brew outdated --quiet 2>/dev/null); then
  count=$(printf '%s\n' "$outdated" | awk 'NF { count++ } END { print count+0 }')
else
  count="?"
fi

sketchybar --set "${NAME:-brew}" "label=$count" icon="􀐛"
