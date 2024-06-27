#!/bin/bash -e

add_to_path() {
    if [[ ":$PATH:" != *":$1:"* && -e "$1" ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}
