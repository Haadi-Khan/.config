pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Loads calendar events for a date range via scripts/events.py.
Singleton {
    id: root

    property var events: []
    property var errors: []
    property bool configured: true
    property bool loading: proc.running

    property string rangeStart: ""
    property string rangeEnd: ""

    function iso(d) { return Qt.formatDate(d, "yyyy-MM-dd"); }

    function load(start, end) {
        rangeStart = iso(start);
        rangeEnd = iso(end);
        proc.running = false;
        proc.running = true;
    }

    function reload() {
        if (rangeStart) { proc.running = false; proc.running = true; }
    }

    // Events overlapping the given day, all-day events first.
    function on(day) {
        const dayStart = new Date(day.getFullYear(), day.getMonth(), day.getDate());
        const dayEnd = new Date(dayStart.getTime() + 86400000);
        const key = iso(dayStart);
        return events.filter(e => {
            if (e.allDay) return e.start <= key && key < e.end;
            const s = new Date(e.start), en = new Date(e.end);
            return s < dayEnd && (en > dayStart || s >= dayStart);
        });
    }

    Process {
        id: proc
        // uv lives in ~/.local/bin, which isn't on the compositor's PATH.
        command: [Quickshell.env("HOME") + "/.local/bin/uv", "run", "--quiet", "--script",
                  Quickshell.shellDir + "/scripts/events.py", root.rangeStart, root.rangeEnd]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text.trim()) return; // failed or restarted; stderr handler reports it
                try {
                    const out = JSON.parse(text);
                    root.events = out.events;
                    root.errors = out.errors;
                    root.configured = out.configured;
                } catch (e) {
                    root.errors = ["events.py: " + e];
                }
            }
        }
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) console.warn("events.py:", text)
        }
    }
}
