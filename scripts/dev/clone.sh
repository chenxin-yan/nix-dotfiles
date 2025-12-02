#!/bin/bash

if [ -z "$1" ]; then
  echo "Usage: $0 <repo_url|owner/repo>"
  exit 1
fi

parse_git_url() {
  local url="$1"
  
  if [[ "$url" =~ ^git@([^:]+):([^/]+)/(.+)(\.git)?$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
    REPO="${REPO%.git}"
    REPO_URL="$url"
  elif [[ "$url" =~ ^https?://([^/]+)/([^/]+)/(.+)$ ]]; then
    HOST="${BASH_REMATCH[1]}"
    OWNER="${BASH_REMATCH[2]}"
    REPO="${BASH_REMATCH[3]}"
    REPO="${REPO%.git}"
    REPO_URL="$url"
  elif [[ "$url" =~ ^([^/]+)/([^/]+)$ ]]; then
    HOST="github.com"
    OWNER="${BASH_REMATCH[1]}"
    REPO="${BASH_REMATCH[2]}"
    REPO_URL="https://github.com/$OWNER/$REPO.git"
  else
    echo "Invalid URL format"
    exit 1
  fi
}

parse_git_url "$1"

REPO_DIR="$DEV_PATH/$HOST/$OWNER/$REPO"

if [ -d "$REPO_DIR" ]; then
  echo "Repository already exists: $REPO_DIR"
  exit 1
fi

git clone "$REPO_URL" "$REPO_DIR"


