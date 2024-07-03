#!/usr/bin/env python3

from session import Window, Session
import session_db
import tmux_new_session
import subprocess

def main():
    session = tmux_new_session.parse_args()
    tmux_new_session.new_session(session)
    session_db.store(session)
    cmd("tmux attach-session -d")

def cmd(cmd):
    output =  subprocess.check_output(cmd, shell=True, text=True).rstrip("\n")

## Python ugliness.
if __name__ == "__main__":
    main()
