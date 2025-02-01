#!/usr/bin/env bash

# Exit on error
set -e

# Dotfiles root directory (automatically set if not provided)
export DOTS="${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Load configuration
source "$DOTS/dots.conf"
source "$DOTS/bin/utils.sh"

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

# Function to install Tmux plugins
install_tmux_plugins() {
    if [ ! -d "$TMUX_TPM_PATH" ]; then
        echo "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$TMUX_TPM_PATH" --depth 1
    fi

    if command -v tmux &>/dev/null; then
        echo "Installing Tmux plugins..."
        "$TMUX_TPM_PATH/bin/install_plugins"
    fi
    e_separator
}

# Function to install Vim plugins
install_vim_plugins() {
    if [ ! -d "$VIM_AUTOLOAD_PATH" ]; then
        mkdir -p "$VIM_AUTOLOAD_PATH"
    fi

    echo "Installing Vim plugins..."
    # Add logic to install plugins from $VIM_DEP_FILE
    e_separator
}

install_gitconfig() {
    echo "Configuring gitconfig..."
    $BIN_PATH/configure-gitconfig.sh install
    e_separator
}

install_bashrc() {
    echo "Configuring bashrc..."
    #Set the path of the bashrc in the ~/.bashrc if already not exists otherwise print the information
    if grep -q "[ -f $DOTS/bash/.bashrc ] && source $DOTS/bash/.bashrc" ~/.bashrc; then
        echo Path already set in $HOME/.bashrc
    else
        echo Setting the DOTS .bashrc path into ~/.bashrc
        echo "[ -f $DOTS/bash/.bashrc ] && source $DOTS/bash/.bashrc" >>~/.bashrc
    fi
    e_separator
}

e_separator
# Create symlinks for dots
link "$DOTS/vim/.vimrc"         "$VIMRC_PATH"
link "$DOTS/bash/.inputrc"      "$INPUTRC_PATH"
link "$DOTS/tmux/.tmux.conf"    "$TMUXCONF_PATH"

# Install plugins
install_bashrc
install_tmux_plugins
# install_vim_plugins
install_gitconfig

# echo "Dots setup complete!"
e_banner "Dots setup complete!"