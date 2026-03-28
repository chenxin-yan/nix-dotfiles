#!/usr/bin/env bash
# Shared helpers for dev scripts.
# Source this file — do not execute directly.

# Parse a git remote URL into HOST, OWNER, REPO (and REPO_URL) global variables.
# Supports SSH, HTTPS, and owner/repo shorthand (defaults to github.com SSH).
parse_git_url() {
  local url="$1"
  if [[ "$url" =~ ^git@([^:]+):([^/]+)/(.+)(\.git)?$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
    REPO_URL="$url"
  elif [[ "$url" =~ ^https?://([^/]+)/([^/]+)/(.+)$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
    REPO_URL="$url"
  elif [[ "$url" =~ ^([^/]+)/([^/]+)$ ]]; then
    HOST="github.com"
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    REPO_URL="git@github.com:$OWNER/$REPO.git"
  else
    echo "Error: Unable to parse URL: $url"
    return 1
  fi
  REPO="${REPO%.git}"
}

# Truncate a session name to fit within the macOS 103-byte sun_path limit
# for zellij Unix domain sockets.
truncate_session_name() {
  local name="$1"
  local zj_base="${TMPDIR%/}/zellij-$(id -u)"
  local zj_subdir
  zj_subdir=$(ls -td "$zj_base"/*/ 2>/dev/null | head -1)
  if [[ -z "$zj_subdir" ]]; then
    local zj_version
    zj_version=$(zellij --version 2>/dev/null | awk '{print $2}')
    zj_subdir="${zj_base}/${zj_version:-00.00.0}/"
  fi
  local max_name_len=$(( 103 - ${#zj_subdir} ))
  if (( ${#name} > max_name_len )); then
    local hash
    hash=$(printf '%s' "$name" | shasum | cut -c1-8)
    name="${name:0:$((max_name_len - 9))}_${hash}"
  fi
  echo "$name"
}

# Convert a directory path to a zellij session name (with truncation).
get_session_name() {
  local dir="$1"
  local name
  if [[ "$dir" == "$DEV_PATH/local/"* ]]; then
    name="local:$(basename "$dir")"
  elif [[ "$dir" == "$DEV_PATH/worktrees/"* ]]; then
    local rel owner repo branch
    rel="${dir#"$DEV_PATH/worktrees"/}"
    owner=$(echo "$rel" | cut -d'/' -f2)
    repo=$(echo "$rel" | cut -d'/' -f3)
    branch=$(echo "$rel" | cut -d'/' -f4)
    name="${owner}:${repo}:${branch}"
  elif [[ "$dir" == "$DEV_PATH"/* ]]; then
    local rel owner repo
    rel="${dir#"$DEV_PATH"/}"
    owner=$(echo "$rel" | cut -d'/' -f2)
    repo=$(echo "$rel" | cut -d'/' -f3)
    name="${owner}:${repo}"
  else
    name=$(basename "$dir")
  fi
  truncate_session_name "$name"
}

# Convert a directory path to a human-readable display name for fzf.
format_display() {
  local dir="$1"
  local rel
  if [[ "$dir" == "$DEV_PATH/local/"* ]]; then
    basename "$dir"
  elif [[ "$dir" == "$DEV_PATH/worktrees/"* ]]; then
    rel="${dir#"$DEV_PATH/worktrees"/}"
    local owner repo branch
    owner=$(echo "$rel" | cut -d'/' -f2)
    repo=$(echo "$rel" | cut -d'/' -f3)
    branch=$(echo "$rel" | cut -d'/' -f4)
    echo "[${branch}]${owner}/${repo}"
  elif [[ "$dir" == "$DEV_PATH"/* ]]; then
    rel="${dir#"$DEV_PATH"/}"
    echo "${rel#*/}"
  else
    basename "$dir"
  fi
}

# Check if a zellij session exists by exact name.
zellij_session_exists() {
  zellij list-sessions --short --no-formatting 2>/dev/null | grep -qxF "$1"
}

# List all project directories (repos, local dirs, worktrees, projects).
list_project_dirs() {
  fd --type d --hidden --max-depth 4 '^\.git$' "$DEV_PATH" --exclude local --exclude worktrees 2>/dev/null | xargs -I{} dirname {}
  fd --type d --max-depth 1 . "$DEV_PATH/local" 2>/dev/null
  fd --type d --exact-depth 4 . "$DEV_PATH/worktrees" 2>/dev/null
  [[ -n "$PROJECTS_PATH" ]] && fd --type d --max-depth 1 . "$PROJECTS_PATH" 2>/dev/null
  true
}
