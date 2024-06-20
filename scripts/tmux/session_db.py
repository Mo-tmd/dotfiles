################################################################################
# Imports
################################################################################
import os
import jason
from session import Window, Session

################################################################################
# Global variables
################################################################################
sessions_file = os.path.dirname(__file__) + '/sessions.json'

################################################################################
# API functions
################################################################################
def store(session:Session):
    sessions = jason.read(sessions_file)
    windows = [{"name":window.name, "start_actions":window.start_actions} for window in session.windows]
    sessions[session.name] = {"windows":windows}
    jason.write(sessions, sessions_file)

def list() -> list[Session]:
    sessions = jason.read(sessions_file)
    sessions_list = [] # Accumulator
    for session_name, windows in sessions.items():
        windows = [Window(name=window['name'], start_actions=window['start_actions']) for window in windows['windows']]
        sessions_list += [Session(name=session_name, windows=windows)]
    return sessions_list

def remove(session_name:str):
    sessions = jason.read(sessions_file)
    try:
        del sessions[session_name]
        jason.write(sessions, sessions_file)
    except KeyError:
        return "Session '{}' does not exist".format(session_name)
