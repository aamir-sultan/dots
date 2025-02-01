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

uninstall_tmux_plugins() {
    echo "Removing tmux plugins and configuration..."
    rm -rf $TMUX_PLUGINS_PATH
    unlink $TMUXCONF_PATH 2>/dev/null
}

uninstall_gitconfig() {
    echo "Removing gitconfig configuration..."
    $BIN_PATH/configure-gitconfig.sh remove
}

# Install plugins
uninstall_tmux_plugins
# install_vim_plugins
uninstall_gitconfig

echo "Dots unistall complete!"