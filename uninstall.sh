#!/usr/bin/env bash

# Exit on error
set -e

# Dotfiles root directory (automatically set if not provided)
DOTS="${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Load configuration
source "$DOTS/dots.conf.sh"

uninstall_tmux_plugins() {
    echo "Removing tmux plugins and configuration..."
    rm -rf $TMUX_PLUGINS_PATH
    [ -f "$TMUXCONF_PATH" ] && unlink $TMUXCONF_PATH || echo "Skipping $TMUXCONF_PATH... Nothing to be done" 
}

uninstall_gitconfig() {
    echo "Removing gitconfig configuration..."
    $BIN_PATH/configure-gitconfig.sh --remove
    # exit 0
}

uninstall_fzf() {
    echo Removing fzf...
    if [ -f $TOOLS/fzf/uninstall ];
    then
        source $TOOLS/fzf/uninstall
    fi
    # exit 0
}

uninstall_bashrc() {
    echo "Removing bashrc configuration..."
    pattern=$(echo "[ -f $DOTS/.anchor ] && source $DOTS/.anchor")
    echo $pattern
    esc_pattern=$(printf '%s\n' "$pattern" | sed -e 's/[\/&]/\\&/g')
    sed -i "/$esc_pattern/d" $BASHRC_PATH
    exit 0
}

uninstall_tools() {
    echo "Removing tools..."
    if [ -d "$DOTS/tools" ];
    then
        rm -rf $DOTS/tools
    fi
}

# Install plugins
uninstall_tmux_plugins
# uninstall_vim_plugins
uninstall_gitconfig
uninstall_fzf
uninstall_tools
uninstall_bashrc
echo "Dots unistall complete!"