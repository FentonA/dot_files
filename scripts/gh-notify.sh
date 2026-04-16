#!/usr/bin/env bash
COUNT=$(gh api notifications | jq length)
if [ "$COUNT" -gt "0" ]; then
  notify-send "GitHub" "$COUNT new notifications"
fi
