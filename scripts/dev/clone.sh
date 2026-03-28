#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib/session.sh"

if [ -z "$1" ]; then
  echo "Usage: $0 <repo_url|owner/repo>"
  exit 1
fi

parse_git_url "$1" || exit 1

REPO_DIR="$DEV_PATH/$HOST/$OWNER/$REPO"

if [ -d "$REPO_DIR" ]; then
  echo "Repository already exists: $REPO_DIR"
  exit 1
fi

git clone "$REPO_URL" "$REPO_DIR"
