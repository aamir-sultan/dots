#!/usr/bin/env bash

# Exit on error
set -e

DOTS="${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Load configuration
CONF_FILE="$(dirname -- "${BASH_SOURCE[0]}")/dots.conf"
if [ ! -f "$CONF_FILE" ]; then
    echo "Error: Configuration file not found at $CONF_FILE"
    exit 1
fi

source "$CONF_FILE"

# Validate NVIM_CONFIG
valid_configs=("LazyVim" "KickStart" "NvChad")
if [[ ! " ${valid_configs[*]} " =~ " ${NVIM_CONFIG} " ]]; then
    echo "Error: Invalid NVIM_CONFIG value. Must be one of: ${valid_configs[*]}"
    exit 1
fi

echo "NVIM_CONFIG: $NVIM_CONFIG"
echo "VIMRC_PATH: $VIMRC_PATH"
echo "BASHRC_PATH: $BASHRC_PATH"
echo "TMUXCONF_PATH: $TMUXCONF_PATH"
echo "GITCONFIG_PATH: $GITCONFIG_PATH"
echo "TMUX_DEP_FILE: $TMUX_DEP_FILE"
echo "VIM_DEP_FILE: $VIM_DEP_FILE"
echo "VIM_AUTOLOAD_PATH: $VIM_AUTOLOAD_PATH"
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
# link_dotfile "$DOTS/git/.gitconfig" "$GITCONFIG_PATH"

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

install_gitconfig() {
    echo "Configuring gitconfig..."
    $BIN_PATH/configure-gitconfig.sh install
}

# Install plugins
# install_tmux_plugins
# install_vim_plugins
install_gitconfig

echo "Dots setup complete!"