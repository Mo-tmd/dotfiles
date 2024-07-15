import os
import json
from pathlib import Path

def read(file:str) -> dict:
    if Path(file).exists():
        with open(file, 'r') as open_file:
            try:
                return json.load(open_file)
            except json.decoder.JSONDecodeError:
                if os.stat(file).st_size == 0:
                    # Empty file, nothing is wrong, don't panic.
                    return {}
                else:
                    raise
    else:
        return {}

def write(some_dict:dict, file:str):
    ensure_file_exists(file)
    with open(file, 'w') as out_file:
        out_file.write(json.dumps(some_dict, indent=4))


def ensure_file_exists(file:str):
    Path(file).touch(exist_ok=True)
