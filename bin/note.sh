#!/usr/bin/bash

note() {
  read -r -d '' usage <<'EOT'
USAGE:
  f [ARGUMENT] [OPTIONS]

ARGUMENT:
  Name a file to open in the editor
  Fzf will be used for the search
  in the Note directory

OPTIONS:
  -h, --help          Display usage text.
EOT

  case $1 in

  "--help")
    echo "$usage"
    return
    ;;

  "-h")
    echo "$usage"
    return
    ;;


  *)
    local file
    local notes_path=
    if [[ -n "$1" ]]; then
      $EDITOR "$notes_path/$1"
    else
      # If fd is not available then use find as default editor
      if [ ! -x "$(which fd 2>/dev/null)" ]; then
        file=$(find "$notes_path" -type f  2>/dev/null | fzf +m) && $EDITOR "$file"
      else
        file=$(fd . -H -I -E .git --type f "$notes_path" 2>/dev/null | fzf +m) && $EDITOR "$file"
      fi
    fi
    return
    ;;
  esac
}
