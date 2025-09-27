#!/bin/bash

# Get all active zellij sessions without formatting
zellij list-sessions --no-formatting | while read -r session_info; do
  # Extract just the session name from the output and strip ANSI color codes
  session_name=$(echo "$session_info" | awk '{print $1}')
  
  # Skip if session_name is empty or "ACTIVE"/"DETECTED" header
  if [[ -z "$session_name" || "$session_name" == "ACTIVE" || "$session_name" == "DETECTED" ]]; then
    continue
  fi
  
  # Convert session name back to directory name (replace '_' with '.')
  dir_name=$(echo "$session_name" | tr '_' '.')
  
  # Check if corresponding directory exists in either DEV_PATH or PROJECTS_PATH
  DEV_FULL_PATH="$DEV_PATH/$dir_name"
  PROJECTS_FULL_PATH="$PROJECTS_PATH/$dir_name"
  
  if [ ! -d "$DEV_FULL_PATH" ] && [ ! -L "$DEV_FULL_PATH" ] && [ ! -d "$PROJECTS_FULL_PATH" ] && [ ! -L "$PROJECTS_FULL_PATH" ]; then
    echo "Killing zellij session: $session_name (Folder does not exist in DEV_PATH or PROJECTS_PATH)"
    zellij delete-session "$session_name" --force
  fi
done
