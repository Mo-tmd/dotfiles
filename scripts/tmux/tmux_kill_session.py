#!/usr/bin/env python3

import os
import subprocess
import session_db

def main():
    if os.environ.get("TMUX") is None:
        raise AssertionError("Not running inside tmux")
    session_name = cmd("tmux display-message -p '#S'")
    session_db.remove(session_name)
    cmd("tmux kill-session")

def cmd(cmd):
    return subprocess.check_output(cmd, shell=True, text=True).rstrip("\n")

## Python ugliness.
if __name__ == "__main__":
    main()
