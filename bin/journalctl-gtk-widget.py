"""Simple widget to display new journalctl lines in a GTK 3.0 widget."""
import difflib
import threading
from subprocess import PIPE
from subprocess import Popen

import gi
from gi.repository import Gtk

gi.require_version("Gtk", "3.0")


class App(Gtk.Window):
    """The application window."""

    def __init__(self):
        Gtk.Window.__init__(self)
        self.connect("delete-event", self.quit)

        # The list of lines read from the log file
        self.current_lines = []

        # The list of previously read lines to compare to the current one
        self.last_lines = []

        # The box to hold the widgets in the window
        self.box = Gtk.VBox()
        self.add(self.box)

        # The text widget to output the log file to
        self.text = Gtk.TextView()
        self.text.set_editable(False)
        self.box.pack_start(self.text, True, True, 0)

        # A button to demonstrate non-blocking
        self.button = Gtk.Button.new_with_label("Click")
        self.box.pack_end(self.button, True, True, 0)

        # Add a timer thread
        self.timer = threading.Timer(0.1, self.read_log)
        self.timer.start()

        self.show_all()

    def quit(self, *args):
        """Quit."""
        # Stop the timer, in case it is still waiting when the window is closed
        self.timer.cancel()
        Gtk.main_quit()

    def read_log(self):
        """Read the log."""

        # Read the log
        self.current_lines = []
        p = Popen(["journalctl", "--user-unit=appToMonitor"], stdout=PIPE)
        with p.stdout:
            for line in iter(p.stdout.readline, b""):
                self.current_lines.append(line.decode("utf-8"))
        p.wait()

        # Compare the log with the previous reading
        for d in difflib.ndiff(self.last_lines, self.current_lines):
            # Check if this is a new line, and if so, add it to the TextView
            if d[0] == "+":
                self.text.set_editable(True)
                self.text.get_buffer().insert_at_cursor(d.replace("+ ", ""))
                self.text.set_editable(False)

        self.last_lines = self.current_lines

        # Reset the timer
        self.timer = threading.Timer(1, self.read_log)
        self.timer.start()


if __name__ == "__main__":
    app = App()
    Gtk.main()
