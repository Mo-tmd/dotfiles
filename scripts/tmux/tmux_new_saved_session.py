#!/usr/bin/env python3

from session import Window, Session
import session_db
import tmux_new_session
import subprocess
import uuid

def main():
    session = tmux_new_session.parse_args()
    if session.name is None:
        session.name = str(uuid.uuid4())
    tmux_new_session.new_session(session)
    session_db.store(session)
    cmd("tmux attach-session -d")

def cmd(cmd):
    subprocess.check_output(cmd, shell=True, text=True).rstrip("\n")

## Python ugliness.
if __name__ == "__main__":
    main()
