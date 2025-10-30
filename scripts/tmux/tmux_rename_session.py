#!/usr/bin/env python3

################################################################################
# Imports
################################################################################
import subprocess
import sys
from session import Session
import session_db

################################################################################
# main
################################################################################
def main():
    old_name = cmd("tmux display-message -p '#{session_name}'")
    new_name = parse_new_name()
    session_db.rename(old_name, new_name)
    cmd("tmux rename-session '{}'".format(new_name))

def cmd(cmd):
    return subprocess.check_output(cmd, shell=True, text=True).rstrip("\n")

def parse_new_name():
    if len(sys.argv) >= 2:
        new_name = sys.argv[1]
        return Session.substitue_special_characters(new_name)
    else:
        print("Error: New session name is required.")
        sys.exit(1)

## Python ugliness.
if __name__ == "__main__":
    main()
