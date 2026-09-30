#!/usr/bin/env bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/lib/session.sh"

# --- Helper Functions ---

is_git_repo() {
  local dir="$1"
  [[ -d "$dir/.git" ]] || [[ -f "$dir/.git" ]]
}

# Clean up empty parent directories
cleanup_empty_parents() {
  local path="$1"
  local base="$2"

  # Get parent directory
  local parent
  parent=$(dirname "$path")

  # Keep cleaning up empty parents until we hit the base
  while [[ "$parent" != "$base" && "$parent" != "/" ]]; do
    if [[ -d "$parent" ]] && [[ -z "$(ls -A "$parent")" ]]; then
      rmdir "$parent" 2>/dev/null || break
      parent=$(dirname "$parent")
    else
      break
    fi
  done
}

# --- Main Script ---

# Ensure required env vars are set
if [[ -z "$DEV_PATH" ]]; then
  echo "Error: DEV_PATH is not set"
  exit 1
fi

# Build list and show fzf picker
SELECTED=$(
  list_project_dirs | sort -u | while read -r dir; do
    printf "%s\t%s\n" "$(format_display "$dir")" "$dir"
  done | fzf --prompt="Select project to remove: " --with-nth=1 | cut -f2
)

[[ -z "$SELECTED" ]] && exit 0

DISPLAY_NAME=$(format_display "$SELECTED")
SESSION_NAME=$(get_session_name "$SELECTED")

# --- Safety Checks ---

# Check if cwd is inside the selected path
CURRENT_DIR=$(pwd)
if [[ "$CURRENT_DIR" == "$SELECTED" || "$CURRENT_DIR" == "$SELECTED/"* ]]; then
  echo "Error: Cannot remove '$DISPLAY_NAME' - you are currently inside this directory"
  echo "Please change to a different directory first."
  exit 1
fi

# Check for uncommitted changes and unpushed commits (only for git repos)
if is_git_repo "$SELECTED"; then
  WARNINGS=()

  # Check for uncommitted changes
  if ! git -C "$SELECTED" diff --quiet 2>/dev/null || ! git -C "$SELECTED" diff --cached --quiet 2>/dev/null; then
    WARNINGS+=("Has uncommitted changes")
  fi

  # Check for untracked files
  if [[ -n "$(git -C "$SELECTED" ls-files --others --exclude-standard 2>/dev/null)" ]]; then
    WARNINGS+=("Has untracked files")
  fi

  # Check for unpushed commits
  UPSTREAM=$(git -C "$SELECTED" rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || echo "")
  if [[ -n "$UPSTREAM" ]]; then
    UNPUSHED=$(git -C "$SELECTED" log '@{upstream}..HEAD' --oneline 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$UNPUSHED" -gt 0 ]]; then
      WARNINGS+=("Has $UNPUSHED unpushed commit(s)")
    fi
  else
    # No upstream set - might have local-only commits
    WARNINGS+=("No upstream branch set (local commits may be lost)")
  fi

  # Display warnings
  if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    echo "Warning for '$DISPLAY_NAME':"
    for warning in "${WARNINGS[@]}"; do
      echo "  - $warning"
    done
    echo ""
  fi
fi

# --- Confirmation ---

printf "Remove '%s'? [y/N] " "$DISPLAY_NAME"
read -r CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
  echo "Aborted."
  exit 0
fi

# --- Removal ---

echo "Removing '$DISPLAY_NAME'..."

# Remove the selected repo or directory.
rm -rf "$SELECTED"

# Clean up empty parent directories (for repos under $DEV_PATH/host/owner/)
if [[ "$SELECTED" == "$DEV_PATH/"* && "$SELECTED" != "$DEV_PATH/local/"* ]]; then
  cleanup_empty_parents "$SELECTED" "$DEV_PATH"
fi

# --- Session Cleanup ---

echo "Closing session/workspace: $SESSION_NAME"
mux_close "$SESSION_NAME"

echo "Removed '$DISPLAY_NAME'"
