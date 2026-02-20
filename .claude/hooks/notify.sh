#!/bin/sh

INPUT=$(cat)

TITLE=$(printf '%s' "$INPUT" | jq -r '.title // "Claude Code"')
MESSAGE=$(printf '%s' "$INPUT" | jq -r '.message // ""')

[ -z "$MESSAGE" ] && exit 0

if command -v terminal-notifier > /dev/null 2>&1; then
  terminal-notifier \
    -title "$TITLE" \
    -message "$MESSAGE" \
    -sound default
else
  osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\" sound name \"default\""
fi

exit 0
