#!/usr/bin/env bash
# scripts/keyboard-macos.sh - CapsLock <-> Ctrl swap, the macOS half of
# scripts/keyboard.sh.
#
# The Linux script sets XKBOPTIONS=ctrl:swapcaps, which is a TWO-WAY swap:
# CapsLock acts as Control *and* Control acts as CapsLock. macOS's System
# Settings > Keyboard > Modifier Keys panel can express the same thing, but it's
# GUI-only and per-attached-keyboard, so it isn't something bootstrap can do for
# you. hidutil is the scriptable equivalent and applies to every keyboard at
# once.
#
# hidutil mappings do NOT survive a reboot, so the mapping is installed as a
# LaunchAgent (RunAtLoad) and also applied immediately to the running session.

set -e

[ "$(uname)" = Darwin ] || {
  echo "===> Not macOS, skipping (see scripts/keyboard.sh)"
  exit 0
}

echo "===> Configuring keyboard (CapsLock <-> Ctrl)..."

LABEL="com.fentona.keyswap"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

# HID usage IDs, keyboard usage page (0x07):
#   0x39 CapsLock   0xE0 LeftControl
# Both directions are listed — one entry alone gives you a second Control and no
# CapsLock at all, which is not what ctrl:swapcaps does.
MAPPING='{"UserKeyMapping":[
{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0},
{"HIDKeyboardModifierMappingSrc":0x7000000E0,"HIDKeyboardModifierMappingDst":0x700000039}
]}'

mkdir -p "$HOME/Library/LaunchAgents"

cat >"$PLIST" <<PLISTEOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL</string>
  <key>ProgramArguments</key>
  <array>
    <string>/usr/bin/hidutil</string>
    <string>property</string>
    <string>--set</string>
    <string>$(echo "$MAPPING" | tr -d '\n ')</string>
  </array>
  <key>RunAtLoad</key>
  <true/>
</dict>
</plist>
PLISTEOF

# bootout then bootstrap, so re-running replaces the agent instead of failing
# with "service already loaded". bootout on a not-loaded label is an error we
# don't care about.
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST"

# Apply now as well — the agent only fires at login, and you want this before
# then rather than after a logout.
/usr/bin/hidutil property --set "$(echo "$MAPPING" | tr -d '\n ')" >/dev/null

echo "===> Keyboard configured (active now, and reapplied at every login)"
echo "     Verify: hidutil property --get UserKeyMapping"
echo "     Undo:   launchctl bootout gui/\$(id -u)/$LABEL && rm $PLIST"
echo "             (plus a reboot, or hidutil --set '{\"UserKeyMapping\":[]}')"
echo ""
echo "     Note: a Bluetooth keyboard that reconnects mid-session may need this"
echo "     rerun. If that gets annoying, Karabiner-Elements handles reconnects"
echo "     properly: brew install --cask karabiner-elements"
