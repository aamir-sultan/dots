#!/usr/bin/env bash

# Exit on error
set -e

# Dotfiles root directory (automatically set if not provided)
export DOTS="${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Load configuration
source "$DOTS/init/dots.conf"

uninstall_tmux_plugins() {
    echo "Removing tmux plugins and configuration..."
    rm -rf $TMUX_PLUGINS_PATH
    [ -f "$TMUXCONF_PATH" ] && unlink $TMUXCONF_PATH || echo "Skipping $TMUXCONF_PATH... Nothing to be done" 
    [ -f "$TMUXCONF_PATH.bak" ] && unlink "$TMUXCONF_PATH.bak" || echo "Skipping $TMUXCONF_PATH.bak... Nothing to be done" 
}

uninstall_vim_plugins() {
    echo "Removing vim plugins and configuration..."
    # vim +'PlugClean --sync' +qa
    [ -f "$VIMRC_PATH" ] && unlink $VIMRC_PATH || echo "Skipping $VIMRC_PATH... Nothing to be done" 
    [ -f "$VIMRC_PATH.bak" ] && unlink "$VIMRC_PATH.bak" || echo "Skipping $VIMRC_PATH.bak... Nothing to be done"
    rm -rf $VIM_AUTOLOAD_PATH
    rm -rf $VIM_PLUGINS_PATH
}

uninstall_gitconfig() {
    echo "Removing gitconfig configuration..."
    $INIT_PATH/configure-gitconfig.sh --remove
}

uninstall_fzf() {
    echo Removing fzf...
    if [ -f $TOOLS/fzf/uninstall ];
    then
        source $TOOLS/fzf/uninstall
    fi

    rm -rf $HOME/.fzf
    rm -rf $HOME/.fzf.bash
}

uninstall_bashrc() {
    echo "Removing bashrc configuration..."
    pattern=$(echo "$ANCHOR_LINE")
    echo $pattern
    esc_pattern=$(printf '%s\n' "$pattern" | sed -e 's/[\/&]/\\&/g')
    sed -i "/$esc_pattern/d" $BASHRC_PATH
}

uninstall_inputrc() {
    echo "Removing inputrc..."
    [ -f "$INPUTRC_PATH" ] && unlink "$INPUTRC_PATH" || echo "Skipping $INPUTRC_PATH... Nothing to be done" 
    [ -f "$INPUTRC_PATH.bak" ] && unlink "$INPUTRC_PATH.bak" || echo "Skipping $INPUTRC_PATH.bak... Nothing to be done" 
}

uninstall_tools() {
    echo "Removing tools..."
    if [ -d "$DOTS/tools" ];
    then
        rm -rf $DOTS/tools
    fi
}

uninstall_nvim_plugins() {
    echo "Removing nvim setting and plugins..."
    [ -f "$XDG_CONFIG_HOME/nvim" ] && unlink "$XDG_CONFIG_HOME/nvim" || echo "Skipping $XDG_CONFIG_HOME/nvim... Nothing to be done" 
    [ -f "$XDG_CONFIG_HOME/nvim.bak" ] && unlink "$XDG_CONFIG_HOME/nvim.bak" || echo "Skipping $XDG_CONFIG_HOME/nvim... Nothing to be done" 
    rm -rf "$HOME/.local/share/nvim"
    rm -rf "$HOME/.local/state/nvim"
    rm -rf $XDG_CONFIG_HOME/nvim* # Dont enclose in "", will not work
}

help() {
  cat <<EOF
usage: $0 [OPTIONS]

    --help               Show this message
    --all                Uninstall everything
    --tools              Uninstall tools 
    --config             Uninstall config 
EOF
  exit 0
}

# Test for known flags
for opt in $@; do
  case $opt in
  --help) help ;;
  --all) all=true;;
  --tools) tools=true;;
  --config) config=true;;
  -* | --*) 
    e_warning "Warning: invalid option $opt"
    help
    exit 1
    ;;
  esac
done

# if [ -z "$1" ]; then
#   e_warning "Warning: No argument passed"
#   help
#   exit 1
# fi

# Uninstall plugins
if [ "$all" == "true" ] || [ "$config" == "true" ] || [ -z "$1" ]; then # Either all or config or when no argument is passed.
uninstall_vim_plugins
# uninstall_inputrc
uninstall_gitconfig
fi

if [ "$all" == "true" ] || [ "$tools" == "true" ]; then
  uninstall_tmux_plugins
  uninstall_fzf
  uninstall_nvim_plugins
  uninstall_tools # Tools should be placed second last.
  uninstall_bashrc
fi

unset DOTS
e_banner "Dots uninstallation complete!"
