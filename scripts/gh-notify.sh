#!/usr/bin/env bash
# GitHub notification poller
# Fetches unread notifications and dispatches each as a desktop notification
# with the source app's brand color (handled by dunstrc per-app rule)

set -euo pipefail

# When run from cron, DBUS_SESSION_BUS_ADDRESS / XDG_RUNTIME_DIR aren't set,
# so notify-send fails with "Cannot autolaunch D-Bus without X11 $DISPLAY".
# Point at the running user session's bus. Don't override if already set
# (interactive shells have richer values we want to keep).
: "${XDG_RUNTIME_DIR:=/run/user/$(id -u)}"
: "${DBUS_SESSION_BUS_ADDRESS:=unix:path=$XDG_RUNTIME_DIR/bus}"
export XDG_RUNTIME_DIR DBUS_SESSION_BUS_ADDRESS

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/gh-notify"
SEEN_FILE="$STATE_DIR/seen.txt"
mkdir -p "$STATE_DIR"
touch "$SEEN_FILE"

# Escape Pango special characters so markup=full doesn't choke on PR titles
escape_pango() {
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g'
}

# Fetch unread notifications as JSON
notifications=$(gh api notifications 2>/dev/null || echo "[]")

while IFS= read -r notif; do
  id=$(echo "$notif" | jq -r '.id')

  # Skip if already seen
  if grep -qx "$id" "$SEEN_FILE"; then
    continue
  fi

  repo=$(echo "$notif" | jq -r '.repository.full_name')
  type=$(echo "$notif" | jq -r '.subject.type') # PullRequest, Issue, Commit, Release
  title=$(echo "$notif" | jq -r '.subject.title')
  reason=$(echo "$notif" | jq -r '.reason') # mention, review_requested, assign, etc.
  api_url=$(echo "$notif" | jq -r '.subject.url // empty')

  # Convert API URL → web URL for click-to-open
  web_url=""
  if [[ -n "$api_url" ]]; then
    web_url=$(echo "$api_url" |
      sed 's|api.github.com/repos|github.com|' |
      sed 's|/pulls/|/pull/|')
  fi

  # Escape for Pango
  safe_repo=$(printf '%s' "$repo" | escape_pango)
  safe_title=$(printf '%s' "$title" | escape_pango)
  safe_reason=$(printf '%s' "$reason" | escape_pango | tr '_' ' ')

  # Pick an icon hint based on type (dunst falls back gracefully if missing)
  case "$type" in
  PullRequest) icon="git-pull-request" ;;
  Issue) icon="bug" ;;
  Release) icon="package" ;;
  Commit) icon="git-commit" ;;
  *) icon="github" ;;
  esac

  summary="$safe_repo · $safe_reason"
  body=$(printf '<b>%s:</b> %s\n%s' "$type" "$safe_title" "$web_url")

  notify-send \
    --app-name="GitHub" \
    --icon="$icon" \
    "$summary" "$body"

  # Mark as seen
  echo "$id" >>"$SEEN_FILE"
done < <(echo "$notifications" | jq -c '.[]')

# Trim seen file to last 500 entries to prevent unbounded growth
if [[ $(wc -l <"$SEEN_FILE") -gt 500 ]]; then
  tail -n 500 "$SEEN_FILE" >"$SEEN_FILE.tmp"
  mv "$SEEN_FILE.tmp" "$SEEN_FILE"
fi
