#!/usr/bin/env bash

# # Define the directory where tools will be installed
# TOOLS="$HOME/tools"
# mkdir -p "$TOOLS"

tools=()
# Define tools with their attributes

declare -A nvim

nvim["name"]="nvim"
nvim["type"]="bin"
nvim["url"]="https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz"
nvim["ssh_url"]="https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz"
nvim["dpath"]="$TOOLS"
nvim["dtool"]="wget"
nvim["version_or_branch"]="v0.9.5"
nvim["switches"]="--directory-prefix=$TOOLS"
nvim["post_proc_command"]="tar xzf nvim-linux64.tar.gz -C $TOOLS"
nvim["src_path"]="$TOOLS/nvim/bin/nvim"
# nvim["sym_path"]="$DOTS/bin/nvim"
nvim["sym_path"]="$TOOLS/bin/nvim"

tools=("${tools[@]}" "nvim") # Append nvim to older values

declare -A rg

rg["name"]="ripgrep" # This name should match the post process command used name and src_path name
rg["type"]="bin"
rg["url"]="https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz"
rg["ssh_url"]="https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz"
rg["dpath"]="$TOOLS"
rg["dtool"]="wget"
rg["version_or_branch"]="v14.1.1"
rg["switches"]="--directory-prefix=$TOOLS"
rg["post_proc_command"]="tar xzf ripgrep-14.1.1-x86_64-unknown-linux-musl.tar.gz -C $TOOLS"
rg["src_path"]="$TOOLS/ripgrep/rg"
# rg["sym_path"]="$DOTS/bin/rg"
rg["sym_path"]="$TOOLS/bin/rg"

tools=("${tools[@]}" "rg") # Append rg to older values

declare -A fd

fd["name"]="fd"
fd["type"]="bin"
fd["url"]="https://github.com/sharkdp/fd/releases/download/v8.7.1/fd-v8.7.1-i686-unknown-linux-musl.tar.gz"
fd["ssh_url"]="https://github.com/sharkdp/fd/releases/download/v8.7.1/fd-v8.7.1-i686-unknown-linux-musl.tar.gz"
fd["dpath"]="$TOOLS"
fd["dtool"]="wget"
fd["version_or_branch"]="v8.7.1"
fd["switches"]="--directory-prefix=$TOOLS"
fd["post_proc_command"]="tar xzf fd-v8.7.1-i686-unknown-linux-musl.tar.gz -C $TOOLS"
fd["src_path"]="$TOOLS/fd/fd"
# fd["sym_path"]="$DOTS/bin/fd"
fd["sym_path"]="$TOOLS/bin/fd"

tools=("${tools[@]}" "fd") # Append fd to older values

declare -A bat

bat["name"]="bat"
bat["type"]="bin"
bat["url"]="https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-i686-unknown-linux-musl.tar.gz"
bat["ssh_url"]="https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-v0.24.0-i686-unknown-linux-musl.tar.gz"
bat["dpath"]="$TOOLS"
bat["dtool"]="wget"
bat["version_or_branch"]="v0.24.0"
bat["switches"]="--directory-prefix=$TOOLS"
bat["post_proc_command"]="tar xzf bat-v0.24.0-i686-unknown-linux-musl.tar.gz -C $TOOLS"
bat["src_path"]="$TOOLS/bat/bat"
# bat["sym_path"]="$DOTS/bin/bat"
bat["sym_path"]="$TOOLS/bin/bat"

tools=("${tools[@]}" "bat") # Append bat to older values

declare -A vivid

vivid["name"]="vivid"
vivid["type"]="bin"
vivid["url"]="https://github.com/sharkdp/vivid/releases/download/v0.9.0/vivid-v0.9.0-x86_64-unknown-linux-musl.tar.gz"
vivid["ssh_url"]="https://github.com/sharkdp/vivid/releases/download/v0.9.0/vivid-v0.9.0-x86_64-unknown-linux-musl.tar.gz"
vivid["dpath"]="$TOOLS"
vivid["dtool"]="wget"
vivid["version_or_branch"]="v0.9.0"
vivid["switches"]="--directory-prefix=$TOOLS"
vivid["post_proc_command"]="tar xzf vivid-v0.9.0-x86_64-unknown-linux-musl.tar.gz -C $TOOLS"
vivid["src_path"]="$TOOLS/vivid/vivid"
# vivid["sym_path"]="$DOTS/bin/vivid"
vivid["sym_path"]="$TOOLS/bin/vivid"

tools=("${tools[@]}" "vivid") # Append vivid to older values

declare -A fzf

fzf["name"]="fzf"
fzf["type"]="bin"
fzf["url"]="https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-linux_amd64.tar.gz"
fzf["ssh_url"]="https://github.com/junegunn/fzf/releases/download/v0.59.0/fzf-0.59.0-linux_amd64.tar.gz"
fzf["dpath"]="$TOOLS/fzf"
fzf["dtool"]="wget"
fzf["version_or_branch"]="v0.59.0"
fzf["switches"]="--directory-prefix=$TOOLS"
# fzf["post_proc_command"]="$TOOLS/fzf/install --key-bindings --completion --update-rc"
fzf["post_proc_command"]="tar xzf fzf-0.59.0-linux_amd64.tar.gz -C $TOOLS" # .bashrc setting are already done in $DOTS/fzf/.fzfrc that why --on-update-rc.
fzf["src_path"]="$TOOLS/fzf/bin/fzf"
# fzf["sym_path"]="$DOTS/bin/fzf"
fzf["sym_path"]="$TOOLS/bin/fzf"

tools=("${tools[@]}" "fzf") # Append fzf to older values

# declare -A fzf

# fzf["name"]="fzf"
# fzf["type"]="repo"
# fzf["url"]="https://github.com/junegunn/fzf.git"
# fzf["ssh_url"]="https://github.com/junegunn/fzf.git"
# fzf["dpath"]="$TOOLS/fzf"
# fzf["dtool"]="git"
# fzf["version_or_branch"]="master"
# fzf["switches"]="--depth 1"
# # fzf["post_proc_command"]="$TOOLS/fzf/install --key-bindings --completion --update-rc"
# fzf["post_proc_command"]="$TOOLS/fzf/install --key-bindings --completion --no-update-rc" # .bashrc setting are already done in $DOTS/fzf/.fzfrc that why --on-update-rc.
# fzf["src_path"]="$TOOLS/fzf/bin/fzf"
# # fzf["sym_path"]="$DOTS/bin/fzf"
# fzf["sym_path"]="$TOOLS/bin/fzf"

# tools=("${tools[@]}" "fzf") # Append fzf to older values

declare -A tmux

tmux["name"]="tmux"
tmux["type"]="bin"
tmux["url"]="https://github.com/aamir-sultan/tmux-static/releases/download/v3.5a/tmux-static-v3.5a.tar.gz"
tmux["ssh_url"]="https://github.com/aamir-sultan/tmux-static/releases/download/v3.5a/tmux-static-v3.5a.tar.gz"
tmux["dpath"]="$TOOLS"
tmux["dtool"]="wget"
tmux["version_or_branch"]="v3.5a"
tmux["switches"]="--directory-prefix=$TOOLS"
tmux["post_proc_command"]="tar xzf tmux-static-v3.5a.tar.gz -C $TOOLS"
tmux["src_path"]="$TOOLS/tmux/tmux"
# tmux["sym_path"]="$DOTS/bin/tmux"
tmux["sym_path"]="$TOOLS/bin/tmux"

tools=("${tools[@]}" "tmux") # Append tmux to older values

# tools=("nvim" "fd" "bat" "vivid" "fzf" "rg")