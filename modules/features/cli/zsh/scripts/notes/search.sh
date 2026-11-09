#!/usr/bin/env bash

# Search notes in ATLAS_PATH and open selected note with EDITOR
# Usage: search.sh [query]

if [ -z "$ATLAS_PATH" ]; then
  echo "Error: ATLAS_PATH environment variable is not set"
  exit 1
fi

if [ ! -d "$ATLAS_PATH" ]; then
  echo "Error: ATLAS_PATH directory does not exist: $ATLAS_PATH"
  exit 1
fi

EDITOR="${EDITOR:-vim}"
INITIAL_QUERY="${*:-}"

selected=$(find "$ATLAS_PATH" -type f \( -name "*.md" -o -name "*.txt" -o -name "*.org" \) 2>/dev/null |
  fzf --query "$INITIAL_QUERY" \
    --preview 'bat --color=always --style=numbers {}' \
    --preview-window 'right,60%,border-left' \
    --header 'Search Notes (Enter to open)' \
    --prompt 'Notes> ')

if [ -n "$selected" ]; then
  $EDITOR "$selected"
fi
