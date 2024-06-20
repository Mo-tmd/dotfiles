class Window:
    def __init__(self, name:str, start_actions:list[str]):
        self.name = name
        self.start_actions = start_actions

    def __str__(self):
        return "window name: {}\nstart_actions: {}".format(self.name, self.start_actions)

class Session:
    def __init__(self, name:str, windows:list[Window]):
        self.name = name
        self.windows = windows

    def __str__(self):
        string = "session name: {}\n\nwindows:\n".format(self.name)
        for window in self.windows:
            string += window.__str__() + "\n\n"
        return string

