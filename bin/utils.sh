#!/bin/bash

# Header logging
e_header() {
    printf "\n$(tput setaf 7)%s$(tput sgr0)\n" "$@"
}

# Success logging
e_success() {
    printf "$(tput setaf 64)✓ %s$(tput sgr0)\n" "$@"
}

# Error logging
e_error() {
    printf "$(tput setaf 1)x %s$(tput sgr0)\n" "$@"
}

# Warning logging
e_warning() {
    printf "$(tput setaf 136)! %s$(tput sgr0)\n" "$@"
}

# Define a function for colored echo
e_color() {
	local color="$1"
	local message="$2"
	local reset="\033[0m" # Reset to default text color

	case "$color" in
	"red") echo -e "\033[31m$message$reset" ;;
	"green") echo -e "\033[32m$message$reset" ;;
	"yellow") echo -e "\033[33m$message$reset" ;;
	"blue") echo -e "\033[34m$message$reset" ;;
	"magenta") echo -e "\033[35m$message$reset" ;;
	"cyan") echo -e "\033[36m$message$reset" ;;
	*) echo "Invalid color. Usage: e_color <color> <message>" return 1 ;;
	esac
}

e_separator() {
	e_color "yellow" "==============================================================================="
	# e_color "yellow" "-------------------------------------------------------------------------------"
}

e_banner() {
	# e_color "yellow" "==============================================================================="
	e_color "green" "###############################################################################"
    e_color "yellow" "                            $1"
	e_color "green" "###############################################################################"
}

e_pwd() {
# echo_sep
echo "Back to `pwd`"
# echo_sep
}

# Logging function
log() {
  echo -e "\n[$(date +"%Y-%m-%d %H:%M:%S")] $1"
}

ask() {
  while true; do
    read -p "$1 ([y]/n) " -r
    REPLY=${REPLY:-"y"}
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      return 1
    elif [[ $REPLY =~ ^[Nn]$ ]]; then
      return 0
    fi
  done
}

# Ask for confirmation before proceeding
continue() {
    printf "\n"
    e_warning "$@"
    read -p "Continue? (y/n) " -n 1
    printf "\n"
}

# Test whether the result of an 'ask' is a confirmation
is_confirmed() {
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      return 0
    fi
    return 1
}

# Test whether we're in a git repo
is_git_repo() {
    $(git rev-parse --is-inside-work-tree &> /dev/null)
}

# Test whether a command exists
# $1 - cmd to test
type_exists() {
    if [ $(type -P $1) ]; then
      return 0
    fi
    return 1
}

# Function to create symlinks
# link() {
#     local source="$1"
#     local target="$2"

#     if [ -e "$target" ]; then
#         echo "Backing up $target to $target.$(date +%s).bak"
#         mv "$target" "$target.bak"
#     fi

#     echo "Creating symlink: $target -> $source"
#     ln -sf "$source" "$target"
# }
link() {
    local source="$1"
    local target="$2"

    if [ -e "$target" ]; then
        echo "Backing up $target to $target.bak"
        mv "$target" "$target.bak"
    fi

    echo "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
}

chkout_branch(){
  repo_name=$1
  branch_name=$2

# e_separator
  # Check if the source directory exists
if [[ ! -d "$repo_name" ]]; then
  echo "The $repo_name directory/repo does not exist in `pwd`"
  exit 1
else
  cd $repo_name && git checkout $branch_name && cd -
  echo "Updating $branch_name branch for $repo_name..."
  git pull
fi  
# e_separator
}

chdir_to_base(){
  echo "Changing path to $DOTS"
  cd $DOTS
}

get_br_name(){
  branch_name=$(git symbolic-ref -q HEAD)
  branch_name=${branch_name##refs/heads/}
  branch_name=${branch_name:-HEAD}
}