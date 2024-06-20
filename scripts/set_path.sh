#!/bin/bash -e

AddToPath() {
    if [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

AddToPath ~/bin
#AddToPath "$HOME/Path with spaces"

echo $PATH
