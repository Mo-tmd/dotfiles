#!/bin/bash -e

AddToPath() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

AddToPath ~/bin
AddToPath /snap/bin
AddToPath "${DotFiles}/scripts"
#AddToPath "$HOME/Path with spaces"

echo $PATH
