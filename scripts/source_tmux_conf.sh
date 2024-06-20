#!/bin/bash -e

if [ -n "$TMUX" ]; then
    tmux source-file ~/.tmux.conf
fi
