#!/usr/bin/env bash

mkdir -p "$DEV_PATH"
mkdir -p "$PROJECTS_PATH"

get_session_name() {
  local dir="$1"
  local name
  if [[ "$dir" == "$DEV_PATH/local/"* ]]; then
    name="local:$(basename "$dir")"
  elif [[ "$dir" == "$DEV_PATH/worktrees/"* ]]; then
    # Worktree: $DEV_PATH/worktrees/host/owner/repo/branch -> owner:repo:branch
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

  # Zellij uses Unix domain sockets at $TMPDIR/zellij-<uid>/<version>/<session_name>.
  # macOS sun_path is 104 bytes including null terminator, so max usable length is 103.
  local zj_version
  zj_version=$(zellij --version 2>/dev/null | awk '{print $2}')
  zj_version="${zj_version:-00.00.0}"
  local socket_prefix="${TMPDIR%/}/zellij-$(id -u)/${zj_version}/"
  local max_name_len=$(( 103 - ${#socket_prefix} ))
  if (( ${#name} > max_name_len )); then
    local hash
    hash=$(printf '%s' "$name" | shasum | cut -c1-8)
    name="${name:0:$((max_name_len - 9))}_${hash}"
  fi

  echo "$name"
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

if [[ -n "$ZELLIJ" || -n "$ZELLIJ_SESSION_NAME" ]]; then
  # Already inside Zellij — open a new tab in the current session instead of nesting
  zellij action new-tab --layout default --cwd "$SELECTED" --name "$SESSION_NAME"
else
  cd "$SELECTED" && zellij attach --create "$SESSION_NAME"
fi
