# Check DOTS is set and is a directory.
# `return`, not `exit`: this file is sourced by an interactive shell, so `exit`
# would close the terminal.
if [[ -z "$DOTS" ]]; then
  echo "Error: DOTS variable is not set." >&2
  return 1 2>/dev/null || exit 1
elif [[ ! -d "$DOTS" ]]; then
  echo "Error: DOTS is not a directory: $DOTS" >&2
  return 1 2>/dev/null || exit 1
fi

[ -n "$PS1" ] && source $DOTS/config/bash/.bash_profile

# [ -r "$DOTS/config/bin/.colors" ] && [ -f "$DOTS/config/bin/.colors" ] && source $DOTS/config/bin/.colors
# [ -r "$DOTS/config/bin/.ls_color" ] && [ -f ""$DOTS/config/bin/.ls_color ] && source $DOTS/config/bin/.ls_color

# Custom setting on top these dotfiles can be added in the *.local files.
[ -f ~/.bash_profile.local ] && source ~/.bash_profile.local
[ -f ~/.bash_prompt.local ] && source ~/.bash_prompt.local
[ -f ~/.exports.local ] && source ~/.exports.local
[ -f ~/.functions.local ] && source ~/.functions.local
[[ -f ~/.aliases.local ]] && source ~/.aliases.local

# Last, so a knob set in the *.local files above (DOTS_GREETING, DOTS_COLOR, ...) is
# already in effect by the time the greeting draws. Guarded on the function existing:
# bash 3 never defines it.
declare -F dots_greeting >/dev/null && dots_greeting
