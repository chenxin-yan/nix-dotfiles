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

# Get list of remote branches
REMOTE_BRANCHES=$(git ls-remote --heads origin | awk '{print $2}' | sed 's|refs/heads/||')

REMOVED_COUNT=0

# Iterate through worktree directories
for worktree_dir in "$WORKTREE_BASE"/*/; do
  [[ ! -d "$worktree_dir" ]] && continue

  # Get branch name from directory (convert - back to / for checking)
  dir_name=$(basename "$worktree_dir")

  # Check the actual branch the worktree is tracking
  if [[ -f "$worktree_dir/.git" ]]; then
    # Get the branch from the worktree's HEAD
    worktree_branch=$(git -C "$worktree_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
  else
    continue
  fi

  # Check if the branch still exists on remote
  if ! echo "$REMOTE_BRANCHES" | grep -qxF "$worktree_branch"; then
    echo "Removing worktree: $dir_name (branch '$worktree_branch' no longer exists on remote)"

    # Remove the worktree
    git worktree remove "$worktree_dir" --force 2>/dev/null || rm -rf "$worktree_dir"

    # Kill associated zellij session
    SESSION_NAME="$OWNER:$REPO:$dir_name"
    if zellij list-sessions --no-formatting 2>/dev/null | grep -q "^$SESSION_NAME "; then
      echo "  Killing zellij session: $SESSION_NAME"
      zellij delete-session "$SESSION_NAME" --force 2>/dev/null || true
    fi

    ((REMOVED_COUNT++))
  fi
done

# Clean up empty parent directories
if [[ -d "$WORKTREE_BASE" ]] && [[ -z "$(ls -A "$WORKTREE_BASE")" ]]; then
  rmdir "$WORKTREE_BASE" 2>/dev/null || true
  # Try to clean up parent dirs too
  rmdir "$DEV_PATH/worktrees/$HOST/$OWNER" 2>/dev/null || true
  rmdir "$DEV_PATH/worktrees/$HOST" 2>/dev/null || true
fi

if [[ $REMOVED_COUNT -eq 0 ]]; then
  echo "No stale worktrees found for $OWNER/$REPO"
else
  echo "Removed $REMOVED_COUNT stale worktree(s)"
fi
