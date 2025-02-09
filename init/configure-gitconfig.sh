#!/bin/bash

# More robust way to handle DOTS (check if it's set and a directory)
if [[ -z "$DOTS" ]]; then
  echo "Error: DOTS variable is not set."
  exit 1
elif [[ ! -d "$DOTS" ]]; then
  echo "Error: DOTS is not a directory: $DOTS"
  exit 1
fi

# List of paths to include (relative to the dotfiles directory)
SSH_INC=(
  "config/git/.gitconfig"
  # "config/git/.gitaliases"
)

LOCAL_INC=(
  "config/git/.gitconfig"
  # "config/git/.gitaliases"
  "config/git/.gitaliases.local"
)

# Function to add multiple include paths
add_include_paths() {
  # Check if the current session is an SSH session
  if [ -n "$SSH_CONNECTION" ]; then
    # This is an SSH session
    echo "SSH session detected. Configuring Git for SSH..."
    PATHS=("${SSH_INC[@]}")
  else
    # This is not an SSH session
    echo "Local session detected. Configuring Git for local use..."
    PATHS=("${LOCAL_INC[@]}")
  fi

  for path in "${PATHS[@]}"; do
    full_path="$DOTS/$path"
    if [ -f "$full_path" ]; then
      echo "Adding Git include path: $full_path"
      # First remove any previous copies from multiple installations and then add a new one
      git config --global --unset-all include.path "$full_path" 2>/dev/null
      git config --global --add include.path "$full_path"
    else
      echo "Warning: File not found - $full_path"
    fi
  done
}

# Function to remove all include paths
remove_include_paths() {
  # Check if the current session is an SSH session
  if [ -n "$SSH_CONNECTION" ]; then
    # This is an SSH session
    echo "SSH session detected. Removing included paths for SSH..."
    PATHS=("${SSH_INC[@]}")
  else
    # This is not an SSH session
    echo "Local session detected. Removing included paths for local use..."
    PATHS=("${LOCAL_INC[@]}")
  fi

  for path in "${PATHS[@]}"; do
    full_path="$DOTS/$path"
    echo "Removing Git include path: $full_path"
    git config --global --unset-all include.path "$full_path" 2>/dev/null
  done
  exit 0
}

# Function to ensure ~/.gitconfig exists
touch_gitconfig() {
  touch ~/.gitconfig
}

# Main script logic
case "$1" in
  --install)
    touch_gitconfig
    add_include_paths
    ;;
  --remove)
    remove_include_paths
    ;;
  *)
    echo "Usage: $0 --{install|remove}"
    echo "  --install: Add multiple include paths to Git config"
    echo "  --remove:  Remove all include paths from Git config"
    exit 1
    ;;
esac
