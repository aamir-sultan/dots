#!/bin/bash

# Path to your dotfiles directory
# DOTS="$HOME/dotfiles"

# List of paths to include (relative to the dotfiles directory)
SSH_INC=(
  "git/gitaliases"
)

LOCAL_INC=(
  "git/gitaliases"
  "git/gitaliases.local"
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
      # First remove any previous copies from multiple installation and then add a new one
      # If the --unset step is not done the same paths are added multiple times
      # git config --global --unset-all include.path "$full_path" 
      git config --global --add include.path "$full_path"
    else
      echo "Warning: File not found - $full_path"
    fi
  done
}

# Function to remove all include paths
remove_include_paths() {
  # echo "Removing all Git include paths..."
  # git config --global --unset-all include.path

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
    if [ -f "$full_path" ]; then
      echo "Adding Git include path: $full_path"
      git config --global --unset-all include.path "$full_path"
    else
      echo "Warning: File not found - $full_path"
    fi
  done
}

# Main script logic
case "$1" in
  install)
    add_include_paths
    ;;
  remove)
    remove_include_paths
    ;;
  *)
    echo "Usage: $0 {install|remove}"
    echo "  install: Add multiple include paths to Git config"
    echo "  remove:  Remove all include paths from Git config"
    exit 1
    ;;
esac