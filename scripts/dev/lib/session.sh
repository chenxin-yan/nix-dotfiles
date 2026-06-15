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

# Multiplexer backend: "zellij" (default) or "herdr". Set DEV_MUX=herdr to
# drive the herdr workflow with the same scripts while comparing the two.
: "${DEV_MUX:=zellij}"

# True when a herdr process is an ancestor of this shell. herdr sets no env
# marker (unlike zellij's $ZELLIJ), so walk the parent chain instead.
_inside_herdr() {
  local pid=$PPID comm
  while [[ -n "$pid" && "$pid" -gt 1 ]]; do
    comm=$(ps -o comm= -p "$pid" 2>/dev/null)
    [[ "${comm##*/}" == herdr ]] && return 0
    pid=$(ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
  done
  return 1
}

_truncate_zellij_name() {
  # macOS 103-byte sun_path limit for zellij Unix domain sockets.
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

# Normalize a raw project identifier into a backend-appropriate label.
# herdr labels have no socket-length limit; zellij names must be truncated.
mux_label() {
  if [[ "$DEV_MUX" == herdr ]]; then
    echo "$1"
  else
    _truncate_zellij_name "$1"
  fi
}

# Convert a directory path to a session/workspace name (backend-normalized).
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
  mux_label "$name"
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

# Print the herdr workspace_id whose label matches $1 exactly, or nothing.
_herdr_workspace_id() {
  herdr workspace list 2>/dev/null \
    | jq -r --arg l "$1" 'first(.result.workspaces[]? | select(.label == $l) | .workspace_id) // empty' 2>/dev/null
}

# Open a project: focus/attach if it exists, else create. ($1=label $2=dir)
# Inside zellij this opens a new tab in the current session.
mux_open() {
  local label="$1" dir="$2"
  if [[ "$DEV_MUX" == herdr ]]; then
    local id; id=$(_herdr_workspace_id "$label")
    if [[ -n "$id" ]]; then herdr workspace focus "$id" >/dev/null
    else herdr workspace create --cwd "$dir" --label "$label" --focus >/dev/null; fi
    # Outside herdr the focus only changed server state; attach so it shows.
    _inside_herdr || herdr
  elif [[ -n "$ZELLIJ" || -n "$ZELLIJ_SESSION_NAME" ]]; then
    zellij action new-tab --layout default --cwd "$dir" --name "$label"
  else
    cd "$dir" && zellij attach --create "$label"
  fi
}

# Switch to a project, creating it if needed. ($1=label $2=dir)
# Inside zellij this switches sessions rather than adding a tab.
mux_switch() {
  local label="$1" dir="$2"
  if [[ "$DEV_MUX" == herdr ]]; then
    local id; id=$(_herdr_workspace_id "$label")
    if [[ -n "$id" ]]; then herdr workspace focus "$id" >/dev/null
    else herdr workspace create --cwd "$dir" --label "$label" --focus >/dev/null; fi
    _inside_herdr || herdr
  elif [[ -n "$ZELLIJ" ]]; then
    if ! mux_list_labels | grep -qxF "$label"; then
      (cd "$dir" && ZELLIJ= ZELLIJ_SESSION_NAME= zellij attach --create-background "$label")
    fi
    zellij action switch-session "$label"
  else
    echo "Attaching to session: $label"
    (cd "$dir" && zellij attach --create "$label")
  fi
}

# Close a project's session/workspace if it exists. ($1=label)
mux_close() {
  local label="$1"
  if [[ "$DEV_MUX" == herdr ]]; then
    local id; id=$(_herdr_workspace_id "$label")
    [[ -n "$id" ]] && herdr workspace close "$id" >/dev/null 2>&1 || true
  elif mux_list_labels | grep -qxF "$label"; then
    zellij delete-session "$label" --force 2>/dev/null || true
  fi
}

# List all live session/workspace labels, one per line.
mux_list_labels() {
  if [[ "$DEV_MUX" == herdr ]]; then
    herdr workspace list 2>/dev/null | jq -r '.result.workspaces[]?.label'
  else
    zellij list-sessions --short --no-formatting 2>/dev/null
  fi
}

# List all project directories (repos, local dirs, worktrees, projects).
list_project_dirs() {
  fd --type d --hidden --max-depth 4 '^\.git$' "$DEV_PATH" --exclude local --exclude worktrees 2>/dev/null | xargs -I{} dirname {}
  fd --type d --max-depth 1 . "$DEV_PATH/local" 2>/dev/null
  fd --type d --exact-depth 4 . "$DEV_PATH/worktrees" 2>/dev/null
  [[ -n "$PROJECTS_PATH" ]] && fd --type d --max-depth 1 . "$PROJECTS_PATH" 2>/dev/null
  true
}
