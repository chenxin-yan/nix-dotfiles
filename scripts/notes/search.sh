#!/usr/bin/env bash

# Search notes in NOTES_PATH and open selected note with EDITOR
# Usage: search.sh [query]

if [ -z "$NOTES_PATH" ]; then
  echo "Error: NOTES_PATH environment variable is not set"
  exit 1
fi

if [ ! -d "$NOTES_PATH" ]; then
  echo "Error: NOTES_PATH directory does not exist: $NOTES_PATH"
  exit 1
fi

EDITOR="${EDITOR:-vim}"
INITIAL_QUERY="${*:-}"

selected=$(find "$NOTES_PATH" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.org" \) 2>/dev/null |
  fzf --query "$INITIAL_QUERY" \
    --preview 'bat --color=always --style=numbers {}' \
    --preview-window 'right,60%,border-left' \
    --header 'Search Notes (Enter to open)' \
    --prompt 'Notes> ')

if [ -n "$selected" ]; then
  $EDITOR "$selected"
fi
