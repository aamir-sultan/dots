#!/bin/bash

# Clean the duplicate entries from the PATH variable
# Use source ./path/to/this/script for correct working.

echo -e "Old PATH:\n ${PATH}"
OLDPATH="$PATH"; NEWPATH=""; colon=""
while [ "${OLDPATH#*:}" != "$OLDPATH" ]
do  entry="${OLDPATH%%:*}"; search=":${OLDPATH#*:}:"
    [ "${search#*:$entry:}" == "$search" ] && NEWPATH="$NEWPATH$colon$entry" && colon=:
    OLDPATH="${OLDPATH#*:}"
done
NEWPATH="$NEWPATH:$OLDPATH"
export PATH="$NEWPATH"

if [[ "$PATH" != "$NEWPATH" ]]; then
    echo -e "\nError: Export of the new PATH was not successful."
else
    echo -e "\nNew PATH successfully updated"
    echo -e "New PATH:\n ${PATH}"
fi
