# SketchyBar

Workspace labels show one icon per open app, using AeroSpace and the installed
`sketchybar-app-font`. They refresh on workspace/focus changes and every five
seconds to catch background window moves and closures. Unknown apps use the
font's default icon. Of workspaces 1–10, the bar shows only those with open windows
and the focused workspace. Switching to an empty workspace reveals it immediately;
leaving it hides it again if it is still empty.
The icon-strip approach is adapted from
https://github.com/josean-dev/dev-environment-files/tree/main/.config/sketchybar.

The Homebrew count includes outdated formulae and casks under Homebrew's default
upgrade rules. It refreshes every 30 minutes, on wake, or when clicked. `?` means
Homebrew failed, not that everything is up to date. A Perl launcher resets
SketchyBar's inherited SIGCHLD handling so Homebrew's cask subprocesses work.
Nothing is upgraded by this widget.

RAM usage appears beside CPU usage as a percentage, refreshed every two seconds.
It estimates used physical RAM from anonymous, wired and compressed memory less
purgeable memory; file cache and disk swap are excluded. Click to open Activity Monitor.

The thermometer beside CPU usage shows average temperature in Celsius, refreshed
every five seconds. Build its local reader with `bash helpers/build-cpu-temperature.sh`.
It follows btop 1.4.7's Apple Silicon sensor selection: eACC/pACC, then PMU tdie,
then SOC MTR sensors. It displays `—` if no valid readings are available. Unlike
btop 1.4.7, it preserves fractional readings until the final rounding step.

The network widget shows a globe and the active Wi-Fi name, VPN, or `Disconnected`.
Wired connections use an Ethernet icon with the wired service name. It reports
network attachment, not an internet probe.
It refreshes every ten seconds and opens Network settings when clicked.
Build the local helper with `bash helpers/build-network.sh`. It is installed at
`~/.cache/sketchybar/NetworkStatus.app` and launched by the widget. To request the
macOS Location Services permission needed for SSIDs, quit the helper and run:

```sh
open -g ~/.cache/sketchybar/NetworkStatus.app --args --authorize
```

Without permission, a connected wireless network is labeled `Wi-Fi`. The helper
reads CoreWLAN network names only; it never requests geographic coordinates or
sends data to a server. Its current reading is stored locally in
`~/.cache/sketchybar/network.json`.

The current-event block reads the title and countdown from Notion Calendar's
native status item and displays that text beside a white marker. The native
SketchyBar alias could not discover that item on this Mac, including during a
2.24.0 test, so this uses a local Accessibility helper instead. Build it with
`bash helpers/build-notion-mirror.sh` and grant **Notion Calendar Mirror** access
in System Settings → Privacy & Security → Accessibility. The app is installed at
`~/.cache/sketchybar/NotionMirror.app`. Notion Calendar must be running with its
menu-bar event title and time enabled. The helper reads only its status item;
it does not access calendar accounts or databases. No screen capture is used.
The widget refreshes every ten seconds and hides when the text cannot be read.
Click it to open Notion Calendar.

The rightmost Skyrons mark is a local copy of
`/Volumes/skyrons/library/logo/logomark/logomark_black.svg`, so it also works when
the volume is unmounted. The PNG is white for visibility on the dark bar. Rebuild:

```sh
magick -background none assets/skyrons.svg -resize 36x36 -channel RGB -negate +channel assets/skyrons.png
```

Reload configuration with `sketchybar --reload`. When using GNU Stow, restow this
directory after adding files so the new items and `assets` directory are linked
under `~/.config/sketchybar`.
