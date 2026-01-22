#!/usr/bin/env bash

set -e

# --- Helper Functions ---

get_session_name() {
  local dir="$1"
  if [[ "$dir" == "$DEV_PATH/local/"* ]]; then
    echo "local:$(basename "$dir")"
  elif [[ "$dir" == "$DEV_PATH/worktrees/"* ]]; then
    # Worktree: $DEV_PATH/worktrees/host/owner/repo/branch -> owner:repo:branch
    local rel owner repo branch
    rel="${dir#"$DEV_PATH/worktrees"/}"
    owner=$(echo "$rel" | cut -d'/' -f2)
    repo=$(echo "$rel" | cut -d'/' -f3)
    branch=$(echo "$rel" | cut -d'/' -f4)
    echo "${owner}:${repo}:${branch}"
  elif [[ "$dir" == "$DEV_PATH"/* ]]; then
    local rel owner repo
    rel="${dir#"$DEV_PATH"/}"
    owner=$(echo "$rel" | cut -d'/' -f2)
    repo=$(echo "$rel" | cut -d'/' -f3)
    echo "${owner}:${repo}"
  else
    basename "$dir"
  fi
}

format_display() {
  local dir="$1"
  local rel
  if [[ "$dir" == "$DEV_PATH/local/"* ]]; then
    basename "$dir"
  elif [[ "$dir" == "$DEV_PATH/worktrees/"* ]]; then
    # Show as [branch]-owner/repo
    rel="${dir#"$DEV_PATH/worktrees"/}"
    local owner repo branch
    owner=$(echo "$rel" | cut -d'/' -f2)
    repo=$(echo "$rel" | cut -d'/' -f3)
    branch=$(echo "$rel" | cut -d'/' -f4)
    echo "[${branch}]${owner}/${repo}"
  elif [[ "$dir" == "$DEV_PATH"/* ]]; then
    # Strip host (e.g. github.com/)
    rel="${dir#"$DEV_PATH"/}"
    echo "${rel#*/}"
  else
    basename "$dir"
  fi
}

is_worktree() {
  local dir="$1"
  [[ "$dir" == "$DEV_PATH/worktrees/"* ]]
}

is_git_repo() {
  local dir="$1"
  [[ -d "$dir/.git" ]] || [[ -f "$dir/.git" ]]
}

# Get main repo path for a worktree
get_main_repo_for_worktree() {
  local worktree_path="$1"
  # Worktree: $DEV_PATH/worktrees/host/owner/repo/branch
  # Main repo: $DEV_PATH/host/owner/repo
  local rel host owner repo
  rel="${worktree_path#"$DEV_PATH/worktrees"/}"
  host=$(echo "$rel" | cut -d'/' -f1)
  owner=$(echo "$rel" | cut -d'/' -f2)
  repo=$(echo "$rel" | cut -d'/' -f3)
  echo "$DEV_PATH/$host/$owner/$repo"
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
  {
    fd --type d --hidden --max-depth 4 '^\.git$' "$DEV_PATH" --exclude local --exclude worktrees 2>/dev/null | xargs -I{} dirname {}
    fd --type d --max-depth 1 . "$DEV_PATH/local" 2>/dev/null
    fd --type d --exact-depth 4 . "$DEV_PATH/worktrees" 2>/dev/null
    [[ -n "$PROJECTS_PATH" ]] && fd --type d --max-depth 1 . "$PROJECTS_PATH" 2>/dev/null
  } | sort -u | while read -r dir; do
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

  # Check for unpushed commits (only for non-worktrees, as worktrees track remote branches)
  if ! is_worktree "$SELECTED"; then
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

if is_worktree "$SELECTED"; then
  # Worktree removal
  MAIN_REPO=$(get_main_repo_for_worktree "$SELECTED")

  if [[ -d "$MAIN_REPO" ]]; then
    # Try to remove via git worktree command
    git -C "$MAIN_REPO" worktree remove "$SELECTED" --force 2>/dev/null || rm -rf "$SELECTED"
  else
    # Main repo doesn't exist, just remove the directory
    rm -rf "$SELECTED"
  fi

  # Clean up empty parent directories
  cleanup_empty_parents "$SELECTED" "$DEV_PATH/worktrees"

else
  # Regular repo/directory removal
  rm -rf "$SELECTED"

  # Clean up empty parent directories (for repos under $DEV_PATH/host/owner/)
  if [[ "$SELECTED" == "$DEV_PATH/"* && "$SELECTED" != "$DEV_PATH/local/"* ]]; then
    cleanup_empty_parents "$SELECTED" "$DEV_PATH"
  fi
fi

# --- Session Cleanup ---

if zellij list-sessions --no-formatting 2>/dev/null | grep -q "^$SESSION_NAME "; then
  echo "Killing zellij session: $SESSION_NAME"
  zellij delete-session "$SESSION_NAME" --force 2>/dev/null || true
fi

echo "Removed '$DISPLAY_NAME'"
