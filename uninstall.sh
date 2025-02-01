#!/usr/bin/env bash

# Exit on error
set -e

# Load configuration
CONF_FILE="$(dirname -- "${BASH_SOURCE[0]}")/dots.conf"
if [ ! -f "$CONF_FILE" ]; then
    echo "Error: Configuration file not found at $CONF_FILE"
    exit 1
fi

source "$CONF_FILE"

remove_gitconfig_configuration() {
    echo "Configuring gitconfig..."
    $BIN_PATH/configure-gitconfig.sh remove
}

# Install plugins
# install_tmux_plugins
# install_vim_plugins
remove_gitconfig_configuration

echo "Dots setup complete!"