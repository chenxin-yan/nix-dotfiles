#!/usr/bin/env bash

session_exists() {
  local session="$1"
  
  if [[ "$session" == local-* ]]; then
    local name="${session#local-}"
    [[ -d "$DEV_PATH/local/$name" ]] && return 0
  elif [[ "$session" =~ ^([^-]+)-(.+)$ ]]; then
    local owner="${BASH_REMATCH[1]}"
    local repo="${BASH_REMATCH[2]}"
    for host_dir in "$DEV_PATH"/*; do
      [[ -d "$host_dir/$owner/$repo" ]] && return 0
    done
  else
    [[ -d "$PROJECTS_PATH/$session" ]] && return 0
  fi
  
  return 1
}

zellij list-sessions --no-formatting 2>/dev/null | while read -r line; do
  session=$(echo "$line" | awk '{print $1}')
  [[ -z "$session" || "$session" == "ACTIVE" || "$session" == "DETECTED" ]] && continue
  
  if ! session_exists "$session"; then
    echo "Killing: $session"
    zellij delete-session "$session" --force
  fi
done
