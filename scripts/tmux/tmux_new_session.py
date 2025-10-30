#!/usr/bin/env python3

################################################################################
# Imports
################################################################################
import argparse
import subprocess
from session import Window, Session

################################################################################
# main
################################################################################
def main():
    session = parse_args()
    new_session(session)
    cmd("tmux attach-session -d")

################################################################################
# API functions
################################################################################
def new_session(session):
    session_name = session.name
    first_window, *remaining_windows = session.windows

    # Create session and handle the first window.
    new_session_cmd = "tmux new-session -d -n '{}'".format(first_window.name)
    if session_name is not None:
        new_session_cmd += " -s '{}'".format(session_name)
    cmd(new_session_cmd)
    execute_start_actions(first_window.start_actions)

    ## Handle the rest of the windows
    for window in remaining_windows:
        cmd("tmux new-window -n '{}'".format(window.name))
        execute_start_actions(window.start_actions)
    if len(remaining_windows) > 0:
        cmd("tmux select-window -n")

def parse_args() -> Session:
    ## Parse arguments
    parser = argparse.ArgumentParser(description="Starts a new tmux session with any number of named windows w/o start actions")
    parser.add_argument("--session-name",
                        "-s",
                        nargs = 1,
                        action = "append",
                        metavar = ("SessionName")
                       )
    parser.add_argument("--window",
                        "-w",
                        nargs = "+",
                        action = "append",
                        metavar = ("WindowName", "StartAction1 StartAction2")
                       )
    args = parser.parse_args()

    ## session_name
    session_names = args.session_name
    if session_names is None:
        session_name = None
    else:
        if len(session_names) > 1:
            parser.error("--session-name appears more than once")
        session_name = session_names[0][0]
        session_name = Session.substitue_special_characters(session_name)

    ## windows
    windows = args.window
    if windows is None:
        windows = [Window(name="WindowName", start_actions=[])]
    else:
        for i, window in enumerate(windows):
            window_name = window.pop(0)
            window_start_actions = window
            windows[i] = Window(name=window_name, start_actions=window_start_actions)

    return Session(session_name, windows)

################################################################################
# Internal functions
################################################################################
def cmd(cmd):
    return subprocess.check_output(cmd, shell=True, text=True).rstrip("\n")

def execute_start_actions(start_actions):
    for start_action in start_actions:
        start_action = start_action.replace("'", "\"")
        cmd("tmux send-keys '{}' C-m".format(start_action))

################################################################################
# Python ugliness
################################################################################
if __name__ == "__main__":
    main()
