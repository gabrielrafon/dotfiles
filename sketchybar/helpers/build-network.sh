#!/bin/bash
set -euo pipefail
helper_dir=$(cd "$(dirname "$0")" && pwd)
bundle="$HOME/.cache/sketchybar/NetworkStatus.app"
mkdir -p "$bundle/Contents/MacOS"
cat > "$bundle/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
<key>CFBundleIdentifier</key><string>local.skyrons.sketchybar.network</string>
<key>CFBundleName</key><string>SketchyBar Network</string>
<key>CFBundleExecutable</key><string>NetworkStatus</string>
<key>CFBundlePackageType</key><string>APPL</string>
<key>CFBundleVersion</key><string>1</string>
<key>LSUIElement</key><true/>
<key>NSLocationUsageDescription</key><string>Show the connected Wi-Fi name in SketchyBar. No geographic location is collected or transmitted.</string>
<key>NSLocationWhenInUseUsageDescription</key><string>Show the connected Wi-Fi name in SketchyBar. No geographic location is collected or transmitted.</string>
</dict></plist>
PLIST
swiftc -O -target "$(uname -m)-apple-macos13.0" "$helper_dir/NetworkStatus.swift" -o "$bundle/Contents/MacOS/NetworkStatus"
codesign --force --sign - "$bundle"
printf '%s\n' "$bundle"
