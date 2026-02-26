#!/usr/bin/env bash

set -e

# Ensure we're in a git repo
if ! git rev-parse --is-inside-work-tree &>/dev/null; then
  echo "Error: Not inside a git repository"
  exit 1
fi

# Get repo root and remote URL
REPO_ROOT=$(git rev-parse --show-toplevel)
REMOTE_URL=$(git remote get-url origin 2>/dev/null)

if [[ -z "$REMOTE_URL" ]]; then
  echo "Error: No 'origin' remote found"
  exit 1
fi

# Parse git remote URL to extract host/owner/repo
parse_git_url() {
  local url="$1"

  if [[ "$url" =~ ^git@([^:]+):([^/]+)/(.+)(\.git)?$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
  elif [[ "$url" =~ ^https?://([^/]+)/([^/]+)/(.+)$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
  else
    echo "Error: Unable to parse remote URL: $url"
    exit 1
  fi

  REPO="${REPO%.git}"
}

parse_git_url "$REMOTE_URL"

WORKTREE_BASE="$DEV_PATH/worktrees/$HOST/$OWNER/$REPO"

# Prune any stale worktree references
git worktree prune

# Check if worktree directory exists
if [[ ! -d "$WORKTREE_BASE" ]]; then
  echo "No worktrees found for $OWNER/$REPO"
  exit 0
fi

# Build list of worktrees with their branch info
WORKTREE_LIST=""
for worktree_dir in "$WORKTREE_BASE"/*/; do
  [[ ! -d "$worktree_dir" ]] && continue

  dir_name=$(basename "$worktree_dir")

  if [[ -f "$worktree_dir/.git" ]]; then
    worktree_branch=$(git -C "$worktree_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
  else
    continue
  fi

  WORKTREE_LIST+="$dir_name ($worktree_branch)"$'\n'
done

# Remove trailing newline
WORKTREE_LIST="${WORKTREE_LIST%$'\n'}"

if [[ -z "$WORKTREE_LIST" ]]; then
  echo "No active worktrees found for $OWNER/$REPO"
  exit 0
fi

# Select worktrees with fzf multi-select
SELECTED=$(echo "$WORKTREE_LIST" | fzf --multi --prompt="Select worktree(s) to delete: " --height=40%)

if [[ -z "$SELECTED" ]]; then
  echo "No worktrees selected"
  exit 0
fi

REMOVED_COUNT=0

while IFS= read -r selection; do
  # Extract directory name (everything before the first space)
  dir_name="${selection%% (*}"

  worktree_dir="$WORKTREE_BASE/$dir_name"

  if [[ ! -d "$worktree_dir" ]]; then
    echo "Worktree directory not found: $dir_name"
    continue
  fi

  echo "Removing worktree: $dir_name"

  # Remove the worktree
  git worktree remove "$worktree_dir" --force 2>/dev/null || rm -rf "$worktree_dir"

  # Kill associated zellij session
  SESSION_NAME="$OWNER:$REPO:$dir_name"
  if zellij list-sessions --no-formatting 2>/dev/null | grep -q "^$SESSION_NAME "; then
    echo "  Killing zellij session: $SESSION_NAME"
    zellij delete-session "$SESSION_NAME" --force 2>/dev/null || true
  fi

  ((REMOVED_COUNT++))
done <<< "$SELECTED"

# Clean up empty parent directories
if [[ -d "$WORKTREE_BASE" ]] && [[ -z "$(ls -A "$WORKTREE_BASE")" ]]; then
  rmdir "$WORKTREE_BASE" 2>/dev/null || true
  rmdir "$DEV_PATH/worktrees/$HOST/$OWNER" 2>/dev/null || true
  rmdir "$DEV_PATH/worktrees/$HOST" 2>/dev/null || true
fi

echo "Removed $REMOVED_COUNT worktree(s)"
