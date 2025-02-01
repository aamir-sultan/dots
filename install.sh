#!/usr/bin/env bash

# Exit on error
set -e

# Set DOTS path if not already set
if [ -z "$DOTS" ]; then
    DOTS="$(dirname -- "${BASH_SOURCE[0]}")"
fi

DOTS=$(realpath "$DOTS")
echo "DOTS: $DOTS"

# Default Neovim configuration
NVIM_CONFIG_DEFAULT="LazyVim" # Other options: KickStart, NvChad, LazyVim
if [ -z "$NVIM_CONFIG" ]; then
    NVIM_CONFIG="$NVIM_CONFIG_DEFAULT"
fi
echo "NVIM_CONFIG: $NVIM_CONFIG"

# Validate NVIM_CONFIG
valid_configs=("LazyVim" "KickStart" "NvChad")
if [[ ! " ${valid_configs[*]} " =~ " ${NVIM_CONFIG} " ]]; then
    echo "Error: Invalid NVIM_CONFIG value. Must be one of: ${valid_configs[*]}"
    exit 1
fi

# Define paths for dotS
VIMRC_PATH=~/.vimrc
BASHRC_PATH=~/.bashrc
TMUXCONF_PATH=~/.tmux.conf
GITCONFIG_PATH=~/.gitconfig

echo "VIMRC_PATH: $VIMRC_PATH"
echo "BASHRC_PATH: $BASHRC_PATH"
echo "TMUXCONF_PATH: $TMUXCONF_PATH"
echo "GITCONFIG_PATH: $GITCONFIG_PATH"

# Define dependency files
TMUX_DEP_FILE="$DOTS/system/tmux_plugs.list"
VIM_DEP_FILE="$DOTS/system/vim_plugs.list"

echo "TMUX_DEP_FILE: $TMUX_DEP_FILE"
echo "VIM_DEP_FILE: $VIM_DEP_FILE"

# Define plugin paths
VIM_BUNDLE_PATH=~/.vim/bundle
VIM_AUTOLOAD_PATH=~/.vim/autoload
VIM_PLUGINS_PATH=~/.vim/dotplugged

TMUX_PLUGINS_PATH=~/.tmux/plugins
TMUX_TPM_PATH="$TMUX_PLUGINS_PATH/tpm"

echo "VIM_BUNDLE_PATH: $VIM_BUNDLE_PATH"
echo "VIM_AUTOLOAD_PATH: $VIM_AUTOLOAD_PATH"
echo "VIM_PLUGINS_PATH: $VIM_PLUGINS_PATH"
echo "TMUX_PLUGINS_PATH: $TMUX_PLUGINS_PATH"
echo "TMUX_TPM_PATH: $TMUX_TPM_PATH"

# Function to create symlinks
link_dotfile() {
    local source="$1"
    local target="$2"

    echo $source
    echo $target

    if [ -e "$target" ]; then
        echo "Backing up $target to $target.bak"
        mv "$target" "$target.bak"
    fi

    echo "Creating symlink: $target -> $source"
    ln -sf "$source" "$target"
}

# Create symlinks for dotS
# link_dotfile "$DOTS/vim/.vimrc" "$VIMRC_PATH"
# link_dotfile "$DOTS/bash/.bashrc" "$BASHRC_PATH"
# link_dotfile "$DOTS/tmux/.tmux.conf" "$TMUXCONF_PATH"
link_dotfile "$DOTS/git/.gitconfig" "$GITCONFIG_PATH"

# Function to install Tmux plugins
install_tmux_plugins() {
    if [ ! -d "$TMUX_TPM_PATH" ]; then
        echo "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$TMUX_TPM_PATH"
    fi

    echo "Installing Tmux plugins..."
    "$TMUX_TPM_PATH/bin/install_plugins"
}

# Function to install Vim plugins
install_vim_plugins() {
    if [ ! -d "$VIM_AUTOLOAD_PATH" ]; then
        mkdir -p "$VIM_AUTOLOAD_PATH"
    fi

    echo "Installing Vim plugins..."
    # Add logic to install plugins from $VIM_DEP_FILE
}

# Install plugins
# install_tmux_plugins
# install_vim_plugins

echo "Dots setup complete!"