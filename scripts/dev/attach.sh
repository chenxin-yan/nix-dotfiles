#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib/session.sh"

mkdir -p "$DEV_PATH"
mkdir -p "$PROJECTS_PATH"

SELECTED=$(
  list_project_dirs | sort -u | while read -r dir; do
    printf "%s\t%s\n" "$(format_display "$dir")" "$dir"
  done | fzf --prompt="Select project: " --with-nth=1 | cut -f2
)

[[ -z "$SELECTED" ]] && exit 1

SESSION_NAME=$(get_session_name "$SELECTED")

if [[ -n "$ZELLIJ" || -n "$ZELLIJ_SESSION_NAME" ]]; then
  # Already inside Zellij — open a new tab in the current session instead of nesting
  zellij action new-tab --layout default --cwd "$SELECTED" --name "$SESSION_NAME"
else
  cd "$SELECTED" && zellij attach --create "$SESSION_NAME"
fi
