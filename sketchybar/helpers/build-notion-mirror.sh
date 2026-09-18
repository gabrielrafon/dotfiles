#!/bin/bash
set -euo pipefail
helper_dir=$(cd "$(dirname "$0")" && pwd)
bundle="$HOME/.cache/sketchybar/NotionMirror.app"
mkdir -p "$bundle/Contents/MacOS"
cat > "$bundle/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.skyrons.sketchybar.notion-mirror</string>
<key>CFBundleName</key><string>Notion Calendar Mirror</string>
<key>CFBundleExecutable</key><string>NotionMirror</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSUIElement</key><true/>
</dict></plist>
PLIST
swiftc -O -target "$(uname -m)-apple-macos13.0" "$helper_dir/NotionMirror.swift" \
  -o "$bundle/Contents/MacOS/NotionMirror"
codesign --force --sign - "$bundle"
