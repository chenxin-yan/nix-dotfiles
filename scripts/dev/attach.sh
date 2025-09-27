#!/bin/bash

# Ensure directories exist
mkdir -p "$DEV_PATH"
mkdir -p "$PROJECTS_PATH"

# Use fd to select a top-level directory in both DEV_PATH and PROJECTS_PATH
SELECTED_DIR=$(
  {
    if [[ -n "$DEV_PATH" && -d "$DEV_PATH" ]]; then
      fd --type d -L --max-depth 1 . "$DEV_PATH"
    fi
    if [[ -n "$PROJECTS_PATH" && -d "$PROJECTS_PATH" ]]; then
      fd --type d -L --max-depth 1 . "$PROJECTS_PATH"
    fi
  } | sort -u | fzf --prompt="Select a project to open: "
)

# Check if a directory was actually selected
if [[ -z "$SELECTED_DIR" ]]; then
  echo "No directory selected."
  exit 1
fi

# Derive zellij session name from the directory name
DIR_NAME=$(basename "$SELECTED_DIR")
SESSION_NAME="${DIR_NAME//./_}"  # replaces '.' with '_'

# With attach_to_session=true, zellij will automatically attach to an existing session
# or create a new one if it doesn't exist
echo "Opening zellij session: $SESSION_NAME"
(cd "$SELECTED_DIR" && zellij attach --create "$SESSION_NAME")
