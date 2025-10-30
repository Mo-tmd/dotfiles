#!/usr/bin/env python3

import session_db
import tmux_new_session
from session import Window, Session

def main():
    for session in session_db.list():
        tmux_new_session.new_session(session)

## Python ugliness
if __name__ == "__main__":
    main()
