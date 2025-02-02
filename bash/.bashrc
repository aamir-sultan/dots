# More robust way to handle DOTS (check if it's set and a directory)
if [[ -z "$DOTS" ]]; then
  echo "Error: DOTS variable is not set."
  exit 1
elif [[ ! -d "$DOTS" ]]; then
  echo "Error: DOTS is not a directory: $DOTS"
  exit 1
fi

[ -n "$PS1" ] && source $DOTS/bash/.bash_profile


# Custom setting on top these dotfiles can be added in the *.local files.
[ -f ~/.bash_profile.local ] && source ~/.bash_profile.local
[ -f ~/.bash_prompt.local ] && source ~/.bash_prompt.local
[ -f ~/.exports.local ] && source ~/.exports.local
[ -f ~/.functions.local ] && source ~/.functions.local
[[ -f ~/.aliases.local ]] && source ~/.aliases.local
