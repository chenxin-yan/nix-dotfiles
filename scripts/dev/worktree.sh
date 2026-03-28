#!/usr/bin/env bash

set -e

source "$(dirname "${BASH_SOURCE[0]}")/lib/session.sh"

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

parse_git_url "$REMOTE_URL"

# Prune any stale worktree references
git worktree prune

# Fetch latest from remote
echo "Fetching from origin..."
git fetch --prune origin

# Get current branch name
CURRENT_BRANCH=$(git branch --show-current)

# Get list of remote branches, excluding HEAD and current branch
BRANCHES=$(git branch -r --format='%(refname:short)' | \
  sed 's|^origin/||' | \
  grep -v '^HEAD$' | \
  grep -vxF "$CURRENT_BRANCH" | \
  sort -u)

if [[ -z "$BRANCHES" ]]; then
  echo "No available remote branches to checkout"
  exit 0
fi

# Select branch with fzf
SELECTED_BRANCH=$(echo "$BRANCHES" | fzf --prompt="Select branch: " --height=40%)

if [[ -z "$SELECTED_BRANCH" ]]; then
  echo "No branch selected"
  exit 0
fi

# Sanitize branch name for directory (replace / with -)
SAFE_BRANCH="${SELECTED_BRANCH//\//-}"

# Calculate paths
WORKTREE_PATH="$DEV_PATH/worktrees/$HOST/$OWNER/$REPO/$SAFE_BRANCH"
SESSION_NAME=$(truncate_session_name "$OWNER:$REPO:$SAFE_BRANCH")

# Create worktree if it doesn't exist
if [[ ! -d "$WORKTREE_PATH" ]]; then
  echo "Creating worktree at: $WORKTREE_PATH"
  git worktree add "$WORKTREE_PATH" "$SELECTED_BRANCH"
fi

# Attach to zellij session
if [[ -n "$ZELLIJ" ]]; then
  # Create session in background if it doesn't already exist, then switch to it
  # Clear ZELLIJ env vars to avoid nesting detection in the subshell
  if ! zellij_session_exists "$SESSION_NAME"; then
    (cd "$WORKTREE_PATH" && ZELLIJ= ZELLIJ_SESSION_NAME= zellij attach --create-background "$SESSION_NAME")
  fi
  zellij action switch-session "$SESSION_NAME"
else
  # Outside zellij - attach normally
  echo "Attaching to session: $SESSION_NAME"
  (cd "$WORKTREE_PATH" && zellij attach --create "$SESSION_NAME")
fi
