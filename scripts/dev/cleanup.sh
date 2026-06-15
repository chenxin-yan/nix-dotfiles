#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib/session.sh"

# Build set of valid workspace labels from all project directories
declare -A valid_labels

while IFS= read -r dir; do
  [[ -z "$dir" ]] && continue
  valid_labels["$(get_session_name "$dir")"]=1
done < <(list_project_dirs)

# Close/kill any live session or workspace whose label is not in the valid set
mux_list_labels | while IFS= read -r label; do
  [[ -z "$label" ]] && continue
  if [[ -z "${valid_labels[$label]+x}" ]]; then
    echo "Closing: $label"
    mux_close "$label"
  fi
done
