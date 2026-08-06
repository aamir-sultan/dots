#!/bin/bash

# Exit on error
set -e

# More robust way to handle DOTS (check if it's set and a directory)
if [[ -z "$DOTS" ]]; then
  echo "Error: DOTS variable is not set."
  exit 1
elif [[ ! -d "$DOTS" ]]; then
  echo "Error: DOTS is not a directory: $DOTS"
  exit 1
fi

# Source the configuration files
source "$DOTS/init/dots.conf"
source "$DOTS/init/tools.conf"

# Function to handle Git repository installation
install_tool_repo() {
  local name="${tool[name]}"
  local git_url="${tool[url]}"
  local path="${tool[dpath]}"
  local hash_or_branch="${tool[version_or_branch]}"
  local clone_switches="${tool[switches]}"
  local install_command="${tool[post_proc_command]}"

  log "Processing Git repository: $name"
  echo "URL:              $git_url"
  echo "Path:             $path"
  echo "Hash/Branch:      $hash_or_branch"
  echo "Clone switches:   $clone_switches"
  echo "Install command:  $install_command"
  echo "-------------------------------------"

  eval path="$path"  # Expand variables

  if [ ! -d "$path" ]; then
    log "Cloning $name into $path"
    git clone $clone_switches "$git_url" "$path"
    cd "$path"
    git fetch
    git checkout "$hash_or_branch"

    if [ -n "$install_command" ]; then
      log "Running install command for $name"
      eval "$install_command"
    fi
  else
    log "$name already exists at $path"
  fi

  cd - > /dev/null
}

# Function to handle Binary tool installation
install_tool_binary() {
  local name="${tool[name]}"
  local url="${tool[url]}"
  local dload_path="${tool[dpath]}"
  local dload_tool="${tool[dtool]}"
  local dload_switches="${tool[switches]}"
  local post_proc_cmd="${tool[post_proc_command]}"

  log "Processing binary: $name"
  echo "URL:                      $url"
  echo "Download Path:            $dload_path"
  echo "Download tool:            $dload_tool"
  echo "Download switches:        $dload_switches"
  echo "Post Processing command:  $post_proc_cmd"
  echo "------------------------------------------"

  eval dload_path="$dload_path"  # Expand variables
  mkdir -p "$dload_path"

  local filename=$(basename "$url")
  local setup_path="$dload_path/$name"
  local file_path="$dload_path/$filename"

  # With --sync, replace an existing install so version bumps in tools.conf
  # take effect -- the `-d "$setup_path"` check below otherwise skips the tool.
  # Backups go in their own directory: a sibling "<name>.bak" would fall inside
  # the "<name>*" glob used after extraction and break the rename.
  local backup_dir="$dload_path/.backup"

  if [ "$sync" = "true" ] && [ -d "$setup_path" ]; then
    if [ "$backup" = "true" ]; then
      log "Backing up existing $name to $backup_dir/$name"
      mkdir -p "$backup_dir"
      rm -rf "${backup_dir:?}/$name"
      mv "$setup_path" "$backup_dir/$name"
    else
      log "Removing existing $name at $setup_path (--sync)"
      rm -rf "$setup_path"
    fi
    # Drop any stale archive so the new version is really fetched.
    rm -f "$file_path"
  fi

  if [ ! -d "$setup_path" ]; then
    if [ ! -f "$file_path" ]; then
      if command -v "$dload_tool" > /dev/null 2>&1; then
        log "Downloading $name using $dload_tool"
        $dload_tool $dload_switches "$url"
      elif command -v curl > /dev/null 2>&1; then
        log "Downloading $name using curl"
        curl -Lo "$file_path" "$url"
      else
        log "Error: Neither $dload_tool nor curl is available."
        exit 1
      fi
    fi

    cd "$dload_path"

    if [ -n "$post_proc_cmd" ]; then
      log "Running post-processing for $name"
      eval "$post_proc_cmd"
      # Remove the archive first so the search below only sees directories.
      rm -rf "$filename"

      # Rename the extracted directory to the plain tool name. Explicit rather
      # than `mv "$name"* "$name"`, which broke whenever anything else in
      # $TOOLS started with the tool name.
      local extracted="" candidate
      for candidate in "$name"*; do
        [ -d "$candidate" ] || continue
        [ "$candidate" = "$name" ] && continue
        case "$candidate" in *.bak) continue ;; esac
        if [ -n "$extracted" ]; then
          log "Error: ambiguous extraction for $name: '$extracted' and '$candidate'"
          return 1
        fi
        extracted="$candidate"
      done

      if [ -z "$extracted" ]; then
        log "Error: could not find extracted directory for $name in $dload_path"
        return 1
      fi

      log "Renaming $extracted -> $name"
      mv "$extracted" "$name"
    fi

    # rm -rf dfile "$filename"
  else
    log "$name already exists at $setup_path"
  fi

  cd - > /dev/null
}

create_tool_symlink() {

  local name="${tool[name]}"
  local src_path="${tool[src_path]}"
  local sym_path="${tool[sym_path]}"

  log "Processing binary:   $name"
  echo "Name:               $name"
  echo "Source Path:        $src_path"
  echo "Symlink Path:       $sym_path"
  echo "------------------------------------------"

  mkdir -p $(dirname $sym_path)
  link "$src_path" "$sym_path"
}

# Main loop to install all tools
install_all_tools() {

  if [[ "${SSH_TTY}" ]]; then
    install_mode="remote"
  else
    install_mode="local"
  fi

  mkdir -p "$TOOLS"
  for tool_name in "${tools[@]}"; do
    # `declare -A tool` does not reset on later iterations, so keys from an
    # earlier tool would leak into the next one.
    unset tool
    # Declare an empty associative array
    declare -A tool
    # Populate tool array by copying from the original
    eval "$(declare -p "$tool_name" | sed "s/declare -A $tool_name/declare -A tool/")"

    # Honour the --[no-]<tool> flags. They live in an `enable_<tool>`
    # namespace so they cannot collide with the associative arrays in
    # tools.conf, which are named after the tools themselves.
    local enable_var="enable_${tool_name}"
    local tool_enabled="${!enable_var-}"
    if [ -z "$tool_enabled" ]; then
      tool_enabled="$default_enable"
    fi
    if [ "$tool_enabled" != "true" ]; then
      log "Skipping $tool_name (disabled)"
      continue
    fi

    local tool_install_mode="${tool[install_mode]}"
    if [[ "$tool_install_mode" == "$install_mode" || "$tool_install_mode" == "all" ]]; then

      local tool_type="${tool[type]}"
      if [[ "$tool_type" == "repo" ]]; then
        install_tool_repo "$tool"
        create_tool_symlink "$tool"
      elif [[ "$tool_type" == "bin" ]]; then
        install_tool_binary "$tool"
        create_tool_symlink "$tool"
      fi
    fi
  done
}


help() {
  cat << EOF
usage: $0 [OPTIONS]

    --help            Show this message
    --all             Download and Install everything that is supported
    --sync            Re-install selected tools, replacing any existing copy.
                      Needed to pick up version bumps in tools.conf, since a
                      tool that is already present is otherwise skipped.
                      Combine with a selection, e.g. '--all --sync'.
    --backup          With --sync, keep the previous copy as <tool>.bak
                      instead of deleting it

  Selection: with --all every tool is installed unless switched off with
  --no-<tool>. Without --all, only the tools named with --<tool> are installed.
    --[no-]fzf        Enable/disable installation of fzf
    --[no-]tmux       Enable/disable installation of tmux
    --[no-]fd         Enable/disable installation of fd
    --[no-]bat        Enable/disable installation of bat
    --[no-]vivid      Enable/disable installation of vivid
    --[no-]nvim       Enable/disable installation of nvim
    --[no-]rg         Enable/disable installation of rg
EOF
exit 0
}

# With --all, every tool is on unless explicitly turned off with --no-<tool>.
# Without it, nothing is installed unless explicitly turned on with --<tool>.
default_enable=false

# Test for known flags.
#
# The `enable_` prefix keeps these apart from the associative arrays in
# tools.conf, which are named after the tools themselves.
for opt in "$@"
do
    case $opt in
        --help)     help ;;
        --sync)     sync=true ;;
        --backup)   backup=true ;;
        --all)
                    default_enable=true
                    backup=true
                    ;;
        --fzf)      enable_fzf=true ;;
        --no-fzf)   enable_fzf=false ;;
        --tmux)     enable_tmux=true ;;
        --no-tmux)  enable_tmux=false ;;
        --fd)       enable_fd=true ;;
        --no-fd)    enable_fd=false ;;
        --bat)      enable_bat=true ;;
        --no-bat)   enable_bat=false ;;
        --vivid)    enable_vivid=true ;;
        --no-vivid) enable_vivid=false ;;
        --nvim)     enable_nvim=true ;;
        --no-nvim)  enable_nvim=false ;;
        --rg)       enable_rg=true ;;
        --no-rg)    enable_rg=false ;;
        -*|--*) e_warning "Warning: invalid option $opt"; help ;;
    esac
done

# Help text
if [[ "$1" == "-h" || "$1" == "" ]]; then
    e_color green "Pass a valid argument"
    help
    # exit
fi

# Start installing all tools
install_all_tools
