unset DOTS
# Check if the DOTS is not set
if [ -z "$DOTS" ]; then
    # Set the DOTS path to the this script and one step beyond.
    DOTS="$(dirname -- "${BASH_SOURCE[0]}")/../"
fi
[ -n "$PS1" ] && source $DOTS/bash/.bash_profile


# Custom setting on top these dotfiles can be added in the *.local files.
[ -f ~/.bash_profile.local ] && source ~/.bash_profile.local
[ -f ~/.bash_prompt.local ] && source ~/.bash_prompt.local
[ -f ~/.exports.local ] && source ~/.exports.local
[ -f ~/.functions.local ] && source ~/.functions.local
[[ -f ~/.aliases.local ]] && source ~/.aliases.local
