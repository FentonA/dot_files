#!/usr/bin/env bash
# Run by dunst for every notification (the [record] rule in dunstrc). Remembers
# which app sent notification $DUNST_ID, because the context menu dunst hands to
# dunst-click.sh names the notification's summary, not its app.

DIR="${XDG_RUNTIME_DIR:-/tmp}/dunst-apps"
mkdir -p "$DIR"
printf '%s\n' "$DUNST_APP_NAME" >"$DIR/$DUNST_ID"
find "$DIR" -type f -mmin +1440 -delete 2>/dev/null
