#!/usr/bin/env bash
# Left-clicking a notification takes you to the app that sent it.
#
# dunst has no "run this on click" hook, but a click bound to `context` pipes
# the notification's actions and URLs to the `dmenu` command and acts on the
# line it prints back. So this stands in for the menu: it answers with the
# default action (which is what makes Slack open the right channel, Thunderbird
# the right mail), and focuses the app's window itself, because sway only marks
# a window urgent when an app asks for focus on its own.
#
# stdin, one line per entry:
#   #<label> (<summary>) [<id>,<action key>]     an action
#   https://...                                  a URL found in the body
#
# More than one action and none of them `default` is a real choice, so that
# still goes to rofi.

SCRIPTS="$(dirname "$(readlink -f "$0")")"
DIR="${XDG_RUNTIME_DIR:-/tmp}/dunst-apps"

entries=$(cat)
actions=$(grep '^#' <<<"$entries")
pick=$(grep -m1 ',default\]$' <<<"$actions")
if [ -z "$pick" ] && [ "$(grep -c . <<<"$actions")" -eq 1 ]; then
  pick="$actions"
fi

browser() {
  local b
  b=$(xdg-settings get default-web-browser 2>/dev/null)
  echo "${b%.desktop}"
}

# Focus now, and once more shortly after: an app that was closed to the tray
# has no window until its own action handler maps one.
focus() {
  "$SCRIPTS/dunst-focus.sh" "$1" && return
  (sleep 1; "$SCRIPTS/dunst-focus.sh" "$1") >/dev/null 2>&1 &
}

if [ -n "$pick" ]; then
  id=$(sed -n 's/.*\[\([0-9]*\),[^]]*\]$/\1/p' <<<"$pick")
  app=$(cat "$DIR/$id" 2>/dev/null)
  rm -f "$DIR/$id"
  case "$app" in
    "") ;;
    # No window of their own — these open in the browser.
    GitHub | Linear) focus "$(browser)" ;;
    *) focus "${app%% *}" ;;
  esac
  printf '%s\n' "$pick"
  # Dismiss it, but only after dunst has delivered the action: a notification
  # closed first never gets its action invoked.
  (sleep 0.5; gdbus call --session --dest org.freedesktop.Notifications \
    --object-path /org/freedesktop/Notifications \
    --method org.freedesktop.Notifications.CloseNotification "$id") >/dev/null 2>&1 &
elif [ -n "$actions" ]; then
  rofi -dmenu -p dunst <<<"$entries"
else
  # URLs only, and the menu line carries no id, so dismiss whatever is on top.
  url=$(head -n1 <<<"$entries")
  [ -n "$url" ] || exit 0
  focus "$(browser)"
  printf '%s\n' "$url"
  (sleep 0.5; dunstctl close) >/dev/null 2>&1 &
fi
