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

LABEL=$(get_session_name "$SELECTED")

mux_open "$LABEL" "$SELECTED"
