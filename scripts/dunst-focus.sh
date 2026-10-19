#!/usr/bin/env bash
# Focus a running app's window, matching the name case-insensitively against
# app_id (Wayland) and class (XWayland). A window hidden in the scratchpad is
# shown. Exits non-zero if nothing matched.
# Usage: dunst-focus.sh <name>

NAME="$1"
[ -n "$NAME" ] || exit 1

swaymsg "[app_id=\"(?i)${NAME}\"] focus" >/dev/null 2>&1 && exit 0
swaymsg "[class=\"(?i)${NAME}\"] focus" >/dev/null 2>&1
