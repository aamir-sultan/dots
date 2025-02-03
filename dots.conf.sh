
# Default Neovim configuration
NVIM_CONFIG_DEFAULT="LazyVim" # Other options: KickStart, NvChad, LazyVim
if [ -z "$NVIM_CONFIG" ]; then
    NVIM_CONFIG="$NVIM_CONFIG_DEFAULT"
fi

# Define paths for dotS
VIMRC_PATH="$HOME/.vimrc"
BASHRC_PATH="$HOME/.bashrc"
INPUTRC_PATH="$HOME/.inputrc"
TMUXCONF_PATH="$HOME/.tmux.conf"
GITCONFIG_PATH="$HOME/.gitconfig"

# Paths for plugins
TMUX_PLUGINS_PATH="$HOME/.tmux/plugins"
TMUX_TPM_PATH="$TMUX_PLUGINS_PATH/tpm"
VIM_AUTOLOAD_PATH="$HOME/.vim/autoload"
VIM_PLUGINS_PATH="$HOME/.vim/dotplugged"

# Define dependency files
TMUX_DEP_FILE="$DOTS/system/tmux_plugs.list"
VIM_DEP_FILE="$DOTS/system/vim_plugs.list"

# Binary path
BIN_PATH="$DOTS/bin"

TOOLS="$DOTS/tools"