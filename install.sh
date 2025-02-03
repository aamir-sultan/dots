#!/usr/bin/env bash

# Exit on error
set -e

# Dotfiles root directory (automatically set if not provided)
DOTS="${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Load configuration
source "$DOTS/dots.conf.sh"
source "$DOTS/bin/utils.sh"

# Validate NVIM_CONFIG
valid_configs=("LazyVim" "KickStart" "NvChad")
if [[ ! " ${valid_configs[*]} " =~ " ${NVIM_CONFIG} " ]]; then
    echo "Error: Invalid NVIM_CONFIG value. Must be one of: ${valid_configs[*]}"
    exit 1
fi


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
    if [ ! "$(which vim)" = "" ]; then
        vimplug_path="$VIM_AUTOLOAD_PATH/plug.vim"
        url="https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim"
        vimrc_path="$VIMRC_PATH"

        if [ ! -f "$vimplug_path" ]; then
            if [ ! "$(which curl)" = "" ]; then
            # c_echo "yellow" "-------------------------------------------------------------------------------"
            curl -fLo "$vimplug_path" \
                --create-dirs \
                "$url" &
            wait $!

            # c_echo "yellow" "-------------------------------------------------------------------------------"
            [ -f "$vimrc_path" ] && echo 'Installing VIM Plugins...' && vim -es -u $VIMRC_PATH -i NONE -c "PlugInstall" -c "qa"
            # c_echo "yellow" "-------------------------------------------------------------------------------"
            [ -f "$vimrc_path" ] && echo 'Updating VIM Plugins...' && vim -es -u $VIMRC_PATH -i NONE -c "PlugUpdate" -c "qa"
            # c_echo "yellow" "-------------------------------------------------------------------------------"
            else
            echo "[ ERROR ] missing curl. Cant't install plug.vim"
            fi
        else
            # c_echo "yellow" "-------------------------------------------------------------------------------"
            echo Installing VIM Plugins...
            vim -es -u $VIMRC_PATH -i NONE -c "PlugInstall" -c "qa"
            # vim -e -u $VIMRC_PATH -i NONE -c "PlugInstall" -c "qa"
            # c_echo "yellow" "-------------------------------------------------------------------------------"
            echo Updating VIM Plugins...
            vim -es -u $VIMRC_PATH -i NONE -c "PlugUpdate" -c "qa"
            # vim -e -u $VIMRC_PATH -i NONE -c "PlugUpdate" -c "qa"
            # c_echo "yellow" "-------------------------------------------------------------------------------"
        fi

        unset vimplug_path url vimrc_path
    fi
    e_separator

    e_color red $?
}

install_gitconfig() {
    echo "Configuring gitconfig..."
    $BIN_PATH/configure-gitconfig.sh --install
    e_separator
}

install_bashrc() {
    echo "Configuring bashrc..."
    #Set the path of the bashrc in the ~/.bashrc if already not exists otherwise print the information
    if grep -q "[ -f $DOTS/.anchor ] && source $DOTS/.anchor" ~/.bashrc; then
        echo Path already set in $HOME/.bashrc
    else
        echo Setting the DOTS .anchor path into ~/.bashrc
        echo "[ -f $DOTS/.anchor ] && source $DOTS/.anchor" >>~/.bashrc
    fi
    # if grep -q "[ -f $DOTS/bash/.bashrc ] && source $DOTS/bash/.bashrc" ~/.bashrc; then
    #     echo Path already set in $HOME/.bashrc
    # else
    #     echo Setting the DOTS .bashrc path into ~/.bashrc
    #     echo "[ -f $DOTS/bash/.bashrc ] && source $DOTS/bash/.bashrc" >>~/.bashrc
    # fi
    e_separator
}

mirror_dotfiles() {
    echo "Mirroring dotfiles..."
    # Create symlinks for dots
    link "$DOTS/vim/.vimrc"         "$VIMRC_PATH"
    link "$DOTS/bash/.inputrc"      "$INPUTRC_PATH"
    link "$DOTS/tmux/.tmux.conf"    "$TMUXCONF_PATH"
    e_separator
}

install_tools() {
    if [ $tools ]; then
        echo "Installing tools..."
        $BIN_PATH/install-tools.sh --all
        e_separator
    fi
}







help() {
  cat << EOF
usage: $0 [OPTIONS]

    --help               Show this message
    --all                Download and Install everything that is supported
    --[no-]fonts         Enable/disable fonts cloning and installation
    --[no-]dotfiles      Enable/disable dotfiles cloning and installation
    --[no-]tools         Enable/disable tools cloning and installation
    --lazyvim            Use LazyVim for NeoVim Configuration
    --kickstart          Use KickStart for NeoVim Configuration. This is the basic config.
    --lazylite           Use Selfdeveloped LazyLite for NeoVim Configuration.
EOF
exit 0
}

# Test for known flags
for opt in $@
do
    case $opt in
        --help) help ;;
        --all) 
                tools=true 
                sync=true
                backup=true 
                ;;
        # --backup) backup=true ;;
        --sync) sync=true ;;
        --fonts) fonts=true ;;
        --no-fonts) fonts=false ;;
        --tools) tools=true ;;
        --no-tools) tools=false ;;
        --lazyvim) nvconfig="LazyVim" ;;
        --kickstart) nvconfig="KickStart" ;;
        --lazylite) nvconfig="LazyLite" ;;
        # --xdg)
        #     prefix='"${XDG_CONFIG_HOME:-$HOME/.config}"/.des'
        #     prefix_expand=${XDG_CONFIG_HOME:-$HOME/.config}/.des
        #     mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/.des"
        -*|--*) e_warning "Warning: invalid option $opt"; help ;;
    esac
done

e_separator
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
e_separator

install_bashrc
install_gitconfig
mirror_dotfiles

# Install plugins
install_tools
install_tmux_plugins
install_vim_plugins

# echo "Dots setup complete!"
e_banner "Dots setup complete!"