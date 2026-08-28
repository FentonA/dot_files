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
#
# ── hidutil is the FALLBACK, not the plan ─────────────────────────────────────
#
# config/karabiner/linux-parity.json does the same swap and, unlike hidutil,
# also does the half that actually matters day to day: Control+C acting as
# Command+C outside terminals, so Caps+C copies the way it does under sway.
# hidutil cannot express that — it only remaps key to key, with no notion of a
# chord or of which app is in front.
#
# The two MUST NOT both be live. hidutil remaps at the HID layer, so Karabiner
# sees keys that are already swapped: its CapsLock rule never fires (no CapsLock
# arrives any more) while its Control rule fires on hidutil's output and turns
# it back into CapsLock. Swapping twice is not swapping. So this script installs
# the hidutil agent only while Karabiner is NOT carrying the swap, and tears it
# down once Karabiner is.

set -e

[ "$(uname)" = Darwin ] || {
  echo "===> Not macOS, skipping (see scripts/keyboard.sh)"
  exit 0
}

LABEL="com.fentona.keyswap"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

# The rule's description, as it is written into karabiner.json when you enable
# it. Its presence there is the only honest test of "Karabiner has the swap" —
# the app being installed proves nothing, since enabling a complex modification
# is a manual step in the GUI and this script cannot do it for you.
KARABINER_JSON="$HOME/.config/karabiner/karabiner.json"
RULE_MARK="CapsLock <-> Control, both ways"

teardown_hidutil() {
  launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
  rm -f "$PLIST"
  /usr/bin/hidutil property --set '{"UserKeyMapping":[]}' >/dev/null 2>&1 || true
}

if [ -f "$KARABINER_JSON" ] && grep -q "$RULE_MARK" "$KARABINER_JSON" 2>/dev/null; then
  echo "===> Karabiner is carrying CapsLock <-> Ctrl — removing the hidutil swap"
  teardown_hidutil
  echo "     Both at once cancel out; Karabiner wins because it also maps"
  echo "     Ctrl+C/V to Cmd+C/V outside terminals, which hidutil cannot."
  exit 0
fi

if [ -d /Applications/Karabiner-Elements.app ]; then
  echo "===> Karabiner-Elements is installed but the parity rule is not enabled."
  echo "     Enable it once, then re-run this script to drop the hidutil swap:"
  echo "       Karabiner-Elements > Settings > Complex Modifications > Add rule"
  echo "       -> \"Linux parity — CapsLock as Control, Control as Command\""
  echo "     Falling back to hidutil for now, so CapsLock still works as Ctrl."
  echo ""
fi

echo "===> Configuring keyboard (CapsLock <-> Ctrl, via hidutil)..."

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
echo "     rerun — Karabiner handles reconnects properly, and gives you the"
echo "     Ctrl+C/V -> Cmd+C/V half as well. See the header of this script."
