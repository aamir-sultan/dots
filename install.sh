#!/usr/bin/env bash

# Exit on error
set -e

# Dotfiles root directory (automatically set if not provided)
DOTS="${DOTS:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"

# Load configuration
source "$DOTS/init/dots.conf"

# Validate NVIM_CONFIG
valid_configs=("LazyVim" "KickStart" "NvChad")
if [[ ! " ${valid_configs[*]} " =~ " ${NVIM_CONFIG} " ]]; then
    echo "Error: Invalid NVIM_CONFIG value. Must be one of: ${valid_configs[*]}"
    exit 1
fi


# Function to install Tmux plugins
install_tmux_plugins() {
    if [ $tmux_plugs ]; then
        if [ ! -d "$TMUX_TPM_PATH" ]; then
            echo "Installing Tmux Plugin Manager (TPM)..."
            git clone https://github.com/tmux-plugins/tpm "$TMUX_TPM_PATH" --depth 1
        fi

        if command -v tmux &>/dev/null; then
            echo "Installing Tmux plugins..."
            "$TMUX_TPM_PATH/bin/install_plugins"
        fi
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
            curl -fLo "$vimplug_path" \
                --create-dirs \
                "$url" &
            wait $!

            [ -f "$vimrc_path" ] && echo 'Installing VIM Plugins...' && vim +'PlugInstall --sync' +qa
            [ -f "$vimrc_path" ] && echo 'Updating VIM Plugins...' && vim +'PlugUpdate --sync' +qa
            # [ -f "$vimrc_path" ] && echo 'Installing VIM Plugins...' && vim -es -u $VIMRC_PATH -i NONE -c "PlugInstall" -c "qa"
            # [ -f "$vimrc_path" ] && echo 'Updating VIM Plugins...' && vim -es -u $VIMRC_PATH -i NONE -c "PlugUpdate" -c "qa"
            else
            echo "[ ERROR ] missing curl. Cant't install plug.vim"
            fi
        else
            echo Installing VIM Plugins...
            # vim -es -u $VIMRC_PATH -i NONE -c "PlugInstall" -c "qa"
            vim +'PlugInstall --sync' +qa
            echo Updating VIM Plugins...
            # vim -es -u $VIMRC_PATH -i NONE -c "PlugUpdate" -c "qa"
            vim +'PlugUpdate --sync' +qa
        fi

        unset vimplug_path url vimrc_path
        echo Vim Plugins installation Completed
    fi
    e_separator
}

install_gitconfig() {
    echo "Configuring gitconfig..."
    $INIT_PATH/configure-gitconfig.sh --install
    e_separator
}

install_bashrc() {
    echo "Configuring bashrc..."
    #Set the path of the bashrc in the ~/.bashrc if already not exists otherwise print the information
    # if grep -q "[ -f $DOTS/.anchor ] && source $DOTS/.anchor" ~/.bashrc; then
    if grep -q "$ANCHOR_LINE" ~/.bashrc; then
        echo Path already set in $HOME/.bashrc
    else
        echo Setting the DOTS .anchor path into ~/.bashrc
        echo "[ -f $DOTS/.anchor ] && source $DOTS/.anchor" >>~/.bashrc
    fi
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
        $INIT_PATH/install-tools.sh --all
        e_separator
    fi
}

configure_nvim() {
    if [ $nvconfig ]; then
        echo "Configuring nvim..."
        if [ "$nvconfig" == "LazyLite" ]; then
            mkdir -p $NVIMCONFIG_PATH
            link "$DOTS/nvim/LazyLite" "$XDG_CONFIG_HOME/nvim"
        fi

        if [ "$nvconfig" == "KickStart" ]; then
            mkdir -p $NVIMCONFIG_PATH
            link "$DOTS/nvim/KickStart" "$XDG_CONFIG_HOME/nvim"
        fi

        if [ "$nvconfig" == "LazyVim" ]; then
            mkdir -p $NVIMCONFIG_PATH
            link "$DOTS/nvim/LazyVim" "$XDG_CONFIG_HOME/nvim"
        fi
        e_separator
    fi
}







help() {
  cat << EOF
usage: $0 [OPTIONS]

    --help               Show this message
    --all                Download and Install everything that is supported
    --[no-]tools         Enable/disable tools cloning and installation
    --[no-]tmux-plugs    Enable/disable tmux plugins cloning and installation
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
                nvconfig="LazyLite"
                tmux_plugs=true 
                tools=true 
                # sync=true
                # backup=true 
                ;;
        # --backup) backup=true ;;
        # --sync) sync=true ;;
        # --fonts) fonts=true ;;
        # --no-fonts) fonts=false ;;
        --tools) tools=true ;;
        --no-tools) tools=false ;;
        --lazylite) nvconfig="LazyLite" ;;
        --lazyvim) nvconfig="LazyVim" ;;
        --kickstart) nvconfig="KickStart" ;;
        --tmux-plugs) tmux_plugs=true ;;
        --no-tmux-plugs) tmux_plugs=false ;;
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
configure_nvim

# echo "Dots setup complete!"
e_banner "Dots setup complete!"