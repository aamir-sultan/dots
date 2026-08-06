# dots

:zap: Dots: Making computers feel like home.

A dotfiles repo that symlinks a set of configs into `$HOME` and, optionally,
installs a curated set of prebuilt CLI binaries into the repo itself. Nothing is
installed system-wide and nothing needs root.

## Contents

- [What it sets up](#what-it-sets-up)
- [Install](#install)
- [Tools](#tools)
- [Uninstall](#uninstall)
- [The `dots` command](#the-dots-command)
- [Layout](#layout)

## What it sets up

Every install, regardless of options:

| Item | Where it lands |
| --- | --- |
| Shell entry point | `[ -f $DOTS/.anchor ] && source $DOTS/.anchor` appended to `~/.bashrc` |
| Git config | via `init/configure-gitconfig.sh --install` |
| vim | `~/.vimrc` -> `config/vim/.vimrc` |
| tmux | `~/.tmux.conf` -> `config/tmux/.tmux.conf` |
| vim plugins | vim-plug into `~/.vim/autoload`, then `PlugInstall` |

Opt-in, via the flags below:

| Item | Flag |
| --- | --- |
| Tool binaries | `--tools` |
| tmux plugins (TPM) | `--tmux-plugs` |
| Neovim config | `--kickstart` or `--lazyvim` |

Sourcing `.anchor` prepends `$DOTS/tools/bin`, `$DOTS/bin` and `~/bin` to `PATH`,
in that order. The tools directory goes first on purpose: the curated binaries
must beat whatever the distro ships (CentOS 7's stock tmux is 1.8, and the
bundled `.tmux.conf` needs 3.2+).

## Install

```sh
git clone https://github.com/aamir-sultan/dots.git ~/.dots
cd ~/.dots
```

### Minimal — configs only

Symlinks the configs, wires up `~/.bashrc` and installs vim plugins. Downloads
no binaries.

```sh
./install.sh
```

### Full — configs, tools and plugins

```sh
./install.sh --all
```

Equivalent to `--tools --tmux-plugs --kickstart`.

### Somewhere in between

Flags are processed left to right, so a later flag overrides an earlier one:
`--all --no-tools` is the full install without the binaries.

| Flag | Effect |
| --- | --- |
| `--help` | Show usage |
| `--all` | Everything supported: tools, tmux plugins, KickStart nvim |
| `--tools` / `--no-tools` | Install the binaries in `init/tools.conf` |
| `--tmux-plugs` / `--no-tmux-plugs` | Install TPM and the tmux plugins |
| `--kickstart` | Use the KickStart Neovim config |
| `--lazyvim` | Use the LazyVim Neovim config |

Open a new shell afterwards, or `source ~/.bashrc`, to pick up `PATH`.

## Tools

Prebuilt static or musl binaries, unpacked into `$DOTS/tools/<name>` and
symlinked into `$DOTS/tools/bin`. They are chosen to run on old glibc: each was
checked to need no symbol newer than glibc 2.17, so they work on CentOS 7.

| Tool | Binary | Installed by `--all` |
| --- | --- | --- |
| Neovim | `nvim` | yes |
| ripgrep | `rg` | yes |
| fd (alternative to find) | `fd` | yes |
| bat (alternative to cat) | `bat` | yes |
| Fuzzy finder | `fzf` | yes |
| Terminal multiplexer | `tmux` | yes |
| vivid (LS_COLORS generator) | `vivid` | no, opt in with `--vivid` |

### Running the tool installer directly

`./install.sh --tools` runs it for you, but it can be driven on its own. It
needs `$DOTS` in the environment, which sourcing `.anchor` provides.

```sh
./init/tools.sh --list          # show the table and what a run would do
./init/tools.sh --all           # install everything eligible
./init/tools.sh --fzf --bat     # just these two
./init/tools.sh --all --no-tmux # everything except tmux
./init/tools.sh --vivid         # opt in to a tool whose mode is 'never'
```

| Flag | Effect |
| --- | --- |
| `--help` | Usage, listing every tool from `init/tools.conf` |
| `--list` | Table of tools with installed version and what this run would do |
| `--all` | Install every tool whose mode matches the session |
| `--sync` | Reinstall even when already present and up to date |
| `--backup` | On reinstall, keep the old copy in `tools/.backup/<name>` |
| `--<tool>` / `--no-<tool>` | Force a single tool on or off, overriding its mode |

Failures are per tool: a download that 404s reports at the end and exits
non-zero, but the remaining tools still install.

### Adding or bumping a tool

Everything lives in [init/tools.conf](init/tools.conf), one whitespace-separated
row per tool. Blank lines and whole-line comments are ignored.

```
# name   version  mode    bin       url
fd       v10.4.2  always  fd        https://github.com/sharkdp/fd/releases/download/{v}/fd-{v}-x86_64-unknown-linux-musl.tar.gz
```

| Column | Meaning |
| --- | --- |
| `name` | Command name, install directory and symlink name |
| `version` | Upstream release, substituted into `url` wherever `{v}` appears |
| `mode` | `never`, `local`, `remote` or `always` (see below) |
| `bin` | Path of the executable inside the unpacked archive |
| `url` | Download url; runs to the end of the line |

`mode` decides when `--all` picks the tool up:

| Mode | Installed by `--all` |
| --- | --- |
| `always` | Every session |
| `local` | Only outside an SSH session |
| `remote` | Only inside an SSH session |
| `never` | Never; only when named, e.g. `--vivid` |

Naming a tool explicitly always overrides its mode, in both directions.

**Bumping a version is a one-field edit.** The installed version is recorded in
`tools/.installed/<name>`, so changing `version` reinstalls that tool on the
next run on its own; `--sync` is not needed for it.

Both archive layouts are handled with no extra configuration: an archive holding
a single top-level directory (nvim, rg, fd, bat, vivid) and one holding a bare
binary (fzf, tmux).

## Uninstall

```sh
cd ~/.dots
./uninstall.sh --all
```

| Flag | Effect |
| --- | --- |
| `--help` | Show usage |
| `--all` | Both of the below |
| `--config` | vim plugins and gitconfig |
| `--tools` | tmux plugins, fzf, nvim plugins and state, `tools/`, and the `~/.bashrc` anchor line |

With no flag at all, only the `--config` half runs.

## The `dots` command

`bin/dots` is a thin wrapper over the two scripts, on `PATH` once `.anchor` has
been sourced:

```sh
dots install --all
dots uninstall --all
dots help
dots install --help
```

It reads `$DOTS` from the environment, so it only works in a shell that has
already sourced `.anchor`. For a fresh clone use `./install.sh` directly.

## Layout

```
.anchor              Entry point sourced from ~/.bashrc; exports $DOTS
install.sh           Config + plugin + tool installer
uninstall.sh         Removes what install.sh added
bin/                 Scripts placed on PATH (dots, autossh, note.sh, ...)
config/              The dotfiles themselves, one directory per program
init/
  dots.conf          Paths and shared variables
  tools.conf         The tool table
  tools.sh           Tool installer
  utils.sh           Logging and symlink helpers
tools/               Installed binaries (git-ignored)
  bin/               Symlinks to each tool's executable, prepended to PATH
  .installed/        Recorded version per tool
  .cache/            Downloaded archives, kept only after a failed install
  .backup/           Previous copies, when --backup is used
```

Local, unversioned tweaks are picked up from `~/.bash_profile.local`,
`~/.bash_prompt.local`, `~/.exports.local`, `~/.functions.local` and
`~/.aliases.local`.
