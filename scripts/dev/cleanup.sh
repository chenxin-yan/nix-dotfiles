#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib/session.sh"

# Build set of valid session names from all project directories
declare -A valid_sessions

while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  name=$(get_session_name "$dir")
  valid_sessions["$name"]=1
done < <(list_project_dirs)

# Kill any running session not in the valid set
zellij list-sessions --short --no-formatting 2>/dev/null | while IFS= read -r session; do
  [[ -z "$session" ]] && continue

  if [[ -z "${valid_sessions[$session]+x}" ]]; then
    echo "Killing: $session"
    zellij delete-session "$session" --force
  fi
done
