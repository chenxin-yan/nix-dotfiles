#!/bin/bash

# Check if the first argument is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <github_repo_url>"
  exit 1
fi

# Get the repository URL from the first argument
REPO_URL=$1

# Check if the project directory exists, if not, create it
if [ ! -d "$DEV_PATH" ]; then
  mkdir -p "$DEV_PATH"
fi

# Get the repository name from the URL
REPO_NAME=$(basename -s .git "$REPO_URL")

# Prompt the user for bare repository clone
read -p "Do you want to clone as a bare repository? [y/N]: " CLONE_BARE
if [ "$CLONE_BARE" == "y" ]; then
  # Clone the repository as bare into the project directory
  cd "$DEV_PATH"
  git clone --bare "$REPO_URL"

  # Check if the clone was successful
  if [ $? -eq 0 ]; then
    echo "Bare repository cloned successfully into $DEV_PATH"
    
    # Change to the bare repository directory
    cd "$DEV_PATH/$REPO_NAME.git"
    
    # Try to add main worktree first, fallback to master
    if git worktree add main; then
      echo "Added 'main' worktree successfully"
    elif git worktree add master; then
      echo "Added 'master' worktree successfully"
    else
      echo "Warning: Could not add 'main' or 'master' worktree"
    fi
  else
    echo "Failed to clone the bare repository"
    exit 1
  fi
else
  # Clone the repository normally into the project directory
  cd "$DEV_PATH"
  git clone "$REPO_URL"

  # Check if the clone was successful
  if [ $? -eq 0 ]; then
    echo "Repository cloned successfully into $DEV_PATH"
  else
    echo "Failed to clone the repository"
    exit 1
  fi
fi


