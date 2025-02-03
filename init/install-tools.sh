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
      # mv "$name"* "$name"
      # echo "Moving ${filename}  to $name"
      rm -rf ${filename}
      mv "$name"* "$name"
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
  mkdir -p "$TOOLS"
  for tool_name in "${tools[@]}"; do
  declare -n tool="$tool_name"  # Crucial: Create a name reference
  local tool_type="${tool[type]}"
    if [[ "$tool_type" == "repo" ]]; then
      install_tool_repo "$tool"
      create_tool_symlink "$tool"
    elif [[ "$tool_type" == "bin" ]]; then
      install_tool_binary "$tool_name"
      create_tool_symlink "$tool"
    fi
  done
}


help() {
  cat << EOF
usage: $0 [OPTIONS]

    --help            Show this message
    --all             Download and Install everything that is supported
    --sync            Sync all of the tools with latest and create backup
    --backup          Create backup all of the tools
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

# Test for known flags
for opt in $@
do
    case $opt in
        --help)     help ;;
        --sync)     sync=true ;; 
        --backup)   backup=true ;; 
        --all) 
                    fzf=true 
                    tmux=true 
                    fd=true 
                    bat=true 
                    vivid=true 
                    nvim=true 
                    rg=true
                    backup=true
                    ;;
        --fzf)      fzf=true ;;
        --no-fzf)   fzf=false ;;
        --tmux)     tmux=true ;;
        --no-tmux)  tmux=false ;;
        --fd)       fd=true ;;
        --no-fd)    fd=false ;;
        --bat)      bat=true ;;
        --no-bat)   bat=false ;;
        --vivid)    vivid=true ;;
        --no-vivid) vivid=false ;;
        --nvim)     nvim=true ;;
        --no-nvim)  nvim=false ;;
        --rg)       rg=true ;;
        --no-rg)    rg=false ;;
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
