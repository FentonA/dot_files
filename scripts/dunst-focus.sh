#!/usr/bin/env bash
# Focus a running app by app_id (Wayland) or class (Xwayland)
# Usage: dunst-focus.sh <app_id> [fallback_class]

APP_ID="$1"
FALLBACK="${2:-$1}"

swaymsg "[app_id=\"^${APP_ID}\$\"] focus" 2>/dev/null && exit 0
swaymsg "[class=\"^${FALLBACK}\$\"] focus" 2>/dev/null && exit 0
swaymsg "[app_id=\".*${APP_ID}.*\"] focus" 2>/dev/null
