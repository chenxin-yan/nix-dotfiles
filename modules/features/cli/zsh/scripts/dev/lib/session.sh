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

# True when a herdr process is an ancestor of this shell. herdr sets no env
# marker, so walk the parent chain instead.
_inside_herdr() {
  local pid=$PPID comm
  while [[ -n "$pid" && "$pid" -gt 1 ]]; do
    comm=$(ps -o comm= -p "$pid" 2>/dev/null)
    [[ "${comm##*/}" == herdr ]] && return 0
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}

# Convert a directory path to a herdr workspace label.
get_session_name() {
  local dir="$1"
  local name
  if [[ "$dir" == "$DEV_PATH/local/"* ]]; then
    name="local:$(basename "$dir")"
  elif [[ "$dir" == "$DEV_PATH"/* ]]; then
    local rel owner repo
    rel="${dir#"$DEV_PATH"/}"
    owner=$(echo "$rel" | cut -d'/' -f2)
    repo=$(echo "$rel" | cut -d'/' -f3)
    name="${owner}:${repo}"
  else
    name=$(basename "$dir")
  fi
  echo "$name"
}

# Convert a directory path to a human-readable display name for fzf.
format_display() {
  local dir="$1"
  local rel
  if [[ "$dir" == "$DEV_PATH/local/"* ]]; then
    basename "$dir"
  elif [[ "$dir" == "$DEV_PATH"/* ]]; then
    rel="${dir#"$DEV_PATH"/}"
    echo "${rel#*/}"
  else
    basename "$dir"
  fi
}

# Print the herdr workspace_id whose label matches $1 exactly, or nothing.
_herdr_workspace_id() {
  herdr workspace list 2>/dev/null \
    | jq -r --arg l "$1" 'first(.result.workspaces[]? | select(.label == $l) | .workspace_id) // empty' 2>/dev/null
}

# Open a project: focus its workspace if it exists, else create. ($1=label $2=dir)
mux_open() {
  local label="$1" dir="$2"
  local id; id=$(_herdr_workspace_id "$label")
  if [[ -n "$id" ]]; then herdr workspace focus "$id" >/dev/null
  else herdr workspace create --cwd "$dir" --label "$label" --focus >/dev/null; fi
  # Outside herdr the focus only changed server state; attach so it shows.
  _inside_herdr || herdr
}

# Close a project's workspace if it exists. ($1=label)
mux_close() {
  local label="$1"
  local id; id=$(_herdr_workspace_id "$label")
  [[ -n "$id" ]] && herdr workspace close "$id" >/dev/null 2>&1 || true
}

# List all live workspace labels, one per line.
mux_list_labels() {
  herdr workspace list 2>/dev/null | jq -r '.result.workspaces[]?.label'
}

# List all project directories (repos and local dirs). Fails rather than
# printing a partial list: cleanup closes every session missing from it.
list_project_dirs() {
  [[ -n "$DEV_PATH" && -d "$DEV_PATH" ]] || { echo "DEV_PATH is not a directory: $DEV_PATH" >&2; return 1; }
  local git_dirs
  git_dirs=$(fd --type d --hidden --max-depth 4 '^\.git$' "$DEV_PATH" --exclude local) || return 1
  [[ -z "$git_dirs" ]] || printf '%s\n' "$git_dirs" | xargs -I{} dirname {}
  if [[ -d "$DEV_PATH/local" ]]; then
    fd --type d --max-depth 1 . "$DEV_PATH/local" || return 1
  fi
}
