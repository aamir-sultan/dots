#!/usr/bin/env bash
#
# Install the binary tools listed in init/tools.conf.
#
# Portability: written against bash 3.2 so it runs on every CentOS in use
# (CentOS 6 ships bash 4.1, CentOS 7 ships 4.2, CentOS 8+ ship 4.4/5.1). That
# rules out associative arrays, namerefs (local -n), negative array indices,
# `wait -n` and ${var@Q}.

set -e

if [ -z "${BASH_VERSINFO[0]}" ] ||
  [ "${BASH_VERSINFO[0]}" -lt 3 ] ||
  { [ "${BASH_VERSINFO[0]}" -eq 3 ] && [ "${BASH_VERSINFO[1]}" -lt 2 ]; }; then
  echo "Error: bash 3.2 or newer is required (found ${BASH_VERSION:-unknown})" >&2
  exit 1
fi

if [ -z "$DOTS" ]; then
  echo "Error: DOTS variable is not set." >&2
  exit 1
elif [ ! -d "$DOTS" ]; then
  echo "Error: DOTS is not a directory: $DOTS" >&2
  exit 1
fi

source "$DOTS/init/dots.conf"

TOOLS_CONF="$INIT_PATH/tools.conf"
BIN_DIR="$TOOLS/bin"
# Dot-prefixed so they never collide with a tool directory: $TOOLS holds only
# one directory per tool, plus bin/ and these.
CACHE_DIR="$TOOLS/.cache"
STAGE_DIR="$TOOLS/.stage"
STATE_DIR="$TOOLS/.installed"
BACKUP_DIR="$TOOLS/.backup"

# ----------------------------------------------------------------------------
# tools.conf
# ----------------------------------------------------------------------------
# Parsed into parallel indexed arrays. One row of the table is one index.
t_names=()
t_versions=()
t_modes=()
t_bins=()
t_urls=()

read_tools_conf() {
  local name version mode bin url lineno=0

  if [ ! -f "$TOOLS_CONF" ]; then
    echo "Error: missing $TOOLS_CONF" >&2
    exit 1
  fi

  # `|| [ -n "$name" ]` so a final line without a trailing newline is not lost.
  while read -r name version mode bin url || [ -n "$name" ]; do
    lineno=$((lineno + 1))

    # Blank lines and whole-line comments. `read` strips leading whitespace, so
    # an indented '#' is caught here too. Comments are whole-line only: the url
    # column runs to the end of the line.
    case "$name" in
    '' | \#*) continue ;;
    esac

    if [ -z "$url" ]; then
      echo "Error: $TOOLS_CONF:$lineno: incomplete row for '$name'" >&2
      exit 1
    fi

    case "$mode" in
    always | local | remote | never) ;;
    *)
      echo "Error: $TOOLS_CONF:$lineno: unknown mode '$mode' for '$name'" >&2
      echo "       expected one of: always local remote never" >&2
      exit 1
      ;;
    esac

    t_names+=("$name")
    t_versions+=("$version")
    t_modes+=("$mode")
    t_bins+=("$bin")
    t_urls+=("${url//\{v\}/$version}")
  done <"$TOOLS_CONF"

  if [ "${#t_names[@]}" -eq 0 ]; then
    echo "Error: $TOOLS_CONF defines no tools" >&2
    exit 1
  fi
}

# Print the table index of tool $1, or fail if there is no such tool.
tool_index() {
  local i
  for i in "${!t_names[@]}"; do
    if [ "${t_names[$i]}" = "$1" ]; then
      printf '%s' "$i"
      return 0
    fi
  done
  return 1
}

# ----------------------------------------------------------------------------
# --<tool> / --no-<tool> overrides
# ----------------------------------------------------------------------------
# A map would be an associative array; with a handful of tools a linear scan
# over two parallel arrays costs nothing and keeps this bash 3.2 clean.
force_names=()
force_values=()

set_force() {
  force_names+=("$1")
  force_values+=("$2")
}

# Print "true", "false", or nothing if the tool was not named on the command
# line. The last flag wins, so `--no-fzf --fzf` installs fzf.
get_force() {
  local i result=""
  for i in "${!force_names[@]}"; do
    if [ "${force_names[$i]}" = "$1" ]; then
      result="${force_values[$i]}"
    fi
  done
  printf '%s' "$result"
}

# ----------------------------------------------------------------------------
# Install steps
# ----------------------------------------------------------------------------

# Download $1 to $2, atomically: a partial transfer never leaves a file that a
# later run would mistake for a complete download.
fetch() {
  local url="$1" out="$2" name="${2##*/}"

  if [ -f "$out" ]; then
    log "Using cached $name"
    return 0
  fi

  mkdir -p "${out%/*}"

  if command -v curl >/dev/null 2>&1; then
    log "Downloading $name with curl"
    if ! curl -fL --retry 3 -o "$out.part" "$url"; then
      rm -f "$out.part"
      return 1
    fi
  elif command -v wget >/dev/null 2>&1; then
    # No --show-progress: that is wget 1.16+, and CentOS 7 ships 1.14.
    log "Downloading $name with wget"
    if ! wget -O "$out.part" "$url"; then
      rm -f "$out.part"
      return 1
    fi
  else
    e_error "Error: neither curl nor wget is available"
    return 1
  fi

  mv "$out.part" "$out"
}

# Unpack archive $1 into directory $2, using a staging directory named after
# tool $3.
#
# Unpacking into a staging directory rather than straight into $TOOLS is what
# lets one code path handle both archive layouts, with no per-tool post
# processing command and no globbing around in a shared directory.
unpack() {
  local archive="$1" dest="$2" name="$3"
  local stage="$STAGE_DIR/$name"
  local payload
  # Declared and assigned separately: `local entries=()` misbehaves on bash 3.2.
  local entries
  entries=()

  rm -rf "$stage"
  mkdir -p "$stage"

  case "$archive" in
  *.tar.gz | *.tgz | *.tar.xz | *.tar.bz2 | *.tar)
    if ! tar xf "$archive" -C "$stage"; then
      rm -rf "$stage"
      return 1
    fi
    ;;
  *.zip)
    if ! command -v unzip >/dev/null 2>&1; then
      e_error "Error: unzip is required to unpack $archive"
      rm -rf "$stage"
      return 1
    fi
    if ! unzip -q "$archive" -d "$stage"; then
      rm -rf "$stage"
      return 1
    fi
    ;;
  *)
    e_error "Error: don't know how to unpack $archive"
    rm -rf "$stage"
    return 1
    ;;
  esac

  # An archive either holds a single top level directory (nvim, rg, fd, bat,
  # vivid) or a bare binary (fzf, tmux). In the first case that directory is
  # the payload; in the second the staging directory itself is.
  entries=("$stage"/*)
  if [ ! -e "${entries[0]}" ]; then
    e_error "Error: $archive unpacked to nothing"
    rm -rf "$stage"
    return 1
  fi

  payload="$stage"
  if [ "${#entries[@]}" -eq 1 ] && [ -d "${entries[0]}" ]; then
    payload="${entries[0]}"
  fi

  rm -rf "$dest"
  mkdir -p "${dest%/*}"
  if ! mv "$payload" "$dest"; then
    rm -rf "$stage"
    return 1
  fi
  rm -rf "$stage"
}

# Point symlink $2 at $1. Idempotent: re-running the installer must not keep
# shuffling an already correct symlink into a .bak.
link_bin() {
  local src="$1" dst="$2"

  mkdir -p "${dst%/*}"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    return 0
  fi

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    echo "Backing up $dst to $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  echo "Linking $dst -> $src"
  ln -sfn "$src" "$dst"
}

# Install the tool at table index $1.
install_tool() {
  local i="$1"
  local name="${t_names[$i]}"
  local version="${t_versions[$i]}"
  local url="${t_urls[$i]}"
  local dest="$TOOLS/${t_names[$i]}"
  local target="$TOOLS/${t_names[$i]}/${t_bins[$i]}"
  local symlink="$BIN_DIR/$name"
  local archive="$CACHE_DIR/${url##*/}"
  local stamp="$STATE_DIR/$name"
  local installed=""

  # The recorded version is what makes a bump in tools.conf take effect without
  # having to remember --sync: an install whose stamp no longer matches the
  # table is replaced.
  if [ -f "$stamp" ]; then
    installed=$(<"$stamp")
  fi

  if [ -d "$dest" ] && [ "$installed" = "$version" ] && [ "$sync" != "true" ]; then
    log "$name $version is up to date"
    link_bin "$target" "$symlink"
    return 0
  fi

  if [ -d "$dest" ]; then
    if [ -n "$installed" ] && [ "$installed" != "$version" ]; then
      log "Upgrading $name: $installed -> $version"
    else
      log "Re-installing $name $version"
    fi

    if [ "$backup" = "true" ]; then
      echo "Backing up $dest to $BACKUP_DIR/$name"
      mkdir -p "$BACKUP_DIR"
      rm -rf "${BACKUP_DIR:?}/$name"
      mv "$dest" "$BACKUP_DIR/$name"
    else
      rm -rf "$dest"
    fi
    # Drop any stale archive so the new version is really fetched.
    rm -f "$archive" "$stamp"
  else
    log "Installing $name $version"
  fi

  echo "  url:      $url"
  echo "  install:  $dest"
  echo "  binary:   $target"
  echo "  symlink:  $symlink"

  fetch "$url" "$archive" || return 1
  unpack "$archive" "$dest" "$name" || return 1

  if [ ! -x "$target" ]; then
    e_error "Error: $name: no executable at $target (check the 'bin' column)"
    return 1
  fi

  mkdir -p "$STATE_DIR"
  printf '%s\n' "$version" >"$stamp"
  rm -f "$archive"

  link_bin "$target" "$symlink"
  e_success "$name $version installed"
}

# ----------------------------------------------------------------------------
# Selection
# ----------------------------------------------------------------------------

# Does the tool at table index $1 get installed in this run?
should_install() {
  local mode="${t_modes[$1]}"
  local forced
  forced=$(get_force "${t_names[$1]}")

  # Naming a tool on the command line overrides its mode either way.
  case "$forced" in
  false) return 1 ;;
  true) return 0 ;;
  esac

  [ "$all" = "true" ] || return 1

  case "$mode" in
  always) return 0 ;;
  never) return 1 ;;
  *) [ "$mode" = "$session" ] ;;
  esac
}

# Point out directories in $TOOLS that no tool in the table claims, e.g. one
# left behind after a tool was renamed or dropped. Never removes anything.
warn_stale() {
  local dir name
  local found=""

  for dir in "$TOOLS"/*; do
    if [ ! -d "$dir" ]; then continue; fi
    name="${dir##*/}"
    if [ "$name" = "bin" ]; then continue; fi
    if tool_index "$name" >/dev/null; then continue; fi
    found="$found $name"
  done

  if [ -n "$found" ]; then
    e_warning "Not listed in $TOOLS_CONF, safe to remove:"
    for name in $found; do
      echo "    rm -rf $TOOLS/$name"
    done
  fi
}

list_tools() {
  local i name version installed action

  echo "Session: $session"
  echo
  printf '  %-8s %-9s %-7s %-9s %s\n' TOOL VERSION MODE INSTALLED "THIS RUN"

  for i in "${!t_names[@]}"; do
    name="${t_names[$i]}"
    version="${t_versions[$i]}"

    installed="-"
    if [ -f "$STATE_DIR/$name" ]; then
      installed=$(<"$STATE_DIR/$name")
    elif [ -d "$TOOLS/$name" ]; then
      installed="unknown"
    fi

    if should_install "$i"; then
      if [ "$installed" = "$version" ] && [ "$sync" != "true" ]; then
        action="up to date"
      elif [ "$installed" = "-" ]; then
        action="install"
      else
        action="upgrade"
      fi
    else
      action="skip"
    fi

    printf '  %-8s %-9s %-7s %-9s %s\n' \
      "$name" "$version" "${t_modes[$i]}" "$installed" "$action"
  done

  echo
  warn_stale
}

help() {
  local i
  cat <<EOF
usage: $0 [OPTIONS]

    --help            Show this message
    --list            Show the tool table and what this run would do
    --all             Install every tool whose mode matches this session
    --sync            Re-install even when already present and up to date.
                      Not needed for version bumps: the installed version is
                      recorded and a change in tools.conf re-installs by itself.
    --backup          On re-install, keep the previous copy under
                      \$TOOLS/.backup/<name> instead of deleting it

  Selection: with --all every tool whose mode matches the session is installed
  unless switched off with --no-<tool>. Without --all, only the tools named
  with --<tool> are installed. Naming a tool overrides its mode, so --vivid
  installs vivid even though its mode is 'never'.

  Tools, from $TOOLS_CONF:

EOF
  for i in "${!t_names[@]}"; do
    printf '    --[no-]%-10s %-9s mode: %s\n' \
      "${t_names[$i]}" "${t_versions[$i]}" "${t_modes[$i]}"
  done
  echo
  exit 0
}

# ----------------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------------

install_all_tools() {
  local i name
  # Declared and assigned separately: `local failed=()` misbehaves on bash 3.2.
  local failed
  failed=()

  mkdir -p "$TOOLS" "$BIN_DIR"

  for i in "${!t_names[@]}"; do
    name="${t_names[$i]}"

    if ! should_install "$i"; then
      if [ "$(get_force "$name")" = "false" ]; then
        log "Skipping $name (--no-$name)"
      elif [ "$all" != "true" ]; then
        log "Skipping $name (not selected; use --all or --$name)"
      elif [ "${t_modes[$i]}" = "never" ]; then
        log "Skipping $name (mode never; use --$name to install it anyway)"
      else
        log "Skipping $name (mode ${t_modes[$i]}, this is a $session session)"
      fi
      continue
    fi

    # `if` so that a failure installs the remaining tools instead of killing
    # the run through set -e.
    if ! install_tool "$i"; then
      e_error "Failed to install $name"
      failed+=("$name")
    fi
    e_separator
  done

  rm -rf "$STAGE_DIR"
  warn_stale

  if [ "${#failed[@]}" -gt 0 ]; then
    e_error "Failed: ${failed[*]}"
    return 1
  fi
}

read_tools_conf

all=false
sync=false
backup=false
list=false

if [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; then
  session="remote"
else
  session="local"
fi

if [ "$#" -eq 0 ]; then
  e_color green "Pass a valid argument"
  help
fi

for opt in "$@"; do
  case "$opt" in
  -h | --help) help ;;
  --list) list=true ;;
  --all) all=true ;;
  --sync) sync=true ;;
  --backup) backup=true ;;
  --no-*)
    name="${opt#--no-}"
    if ! tool_index "$name" >/dev/null; then
      e_warning "Warning: --no-$name names no tool in $TOOLS_CONF"
      help
    fi
    set_force "$name" false
    ;;
  --*)
    name="${opt#--}"
    if ! tool_index "$name" >/dev/null; then
      e_warning "Warning: invalid option $opt"
      help
    fi
    set_force "$name" true
    ;;
  *)
    e_warning "Warning: invalid option $opt"
    help
    ;;
  esac
done

if [ "$list" = "true" ]; then
  list_tools
  exit 0
fi

install_all_tools
