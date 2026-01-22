#!/usr/bin/env bash

mkdir -p "$DEV_PATH"
mkdir -p "$PROJECTS_PATH"

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

SELECTED=$(
  {
    fd --type d --hidden --max-depth 4 '^\.git$' "$DEV_PATH" --exclude local --exclude worktrees 2>/dev/null | xargs -I{} dirname {}
    fd --type d --max-depth 1 . "$DEV_PATH/local" 2>/dev/null
    fd --type d --exact-depth 4 . "$DEV_PATH/worktrees" 2>/dev/null
    fd --type d --max-depth 1 . "$PROJECTS_PATH" 2>/dev/null
  } | sort -u | while read -r dir; do
    printf "%s\t%s\n" "$(format_display "$dir")" "$dir"
  done | fzf --prompt="Select project: " --with-nth=1 | cut -f2
)

[[ -z "$SELECTED" ]] && exit 1

SESSION_NAME=$(get_session_name "$SELECTED")
(cd "$SELECTED" && zellij attach --create "$SESSION_NAME")
