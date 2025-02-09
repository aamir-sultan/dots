#!/usr/bin/env bash

for file in $DOTS/config/*/.{path,env,exports,aliases,functions,keybindings,ls_color,colors,bash_prompt}; do
  # [ -r "$file" ] && [ -f "$file" ] && source "$file"
  [ -r "$file" ] && [ -f "$file" ] && source "$file" || echo "Error sourcing: $file" # Check source success/failure;
done
unset file

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob

# Append to the Bash history file, rather than overwriting it
shopt -s histappend

# Autocorrect typos in path names when using `cd`
shopt -s cdspell

# Enable some Bash 4 features when possible:
# * `autocd`, e.g. `**/qux` will enter `./foo/bar/baz/qux`
# * Recursive globbing, e.g. `echo **/*.txt`
for option in autocd globstar; do
  shopt -s "$option" 2>/dev/null
done

# Enable tab completion for `g` by marking it as an alias for `git`
if type _git &>/dev/null; then
  complete -o default -o nospace -F _git g
fi
