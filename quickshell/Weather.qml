pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Current weather, read from the cache the waybar weather module writes
// (~/.config/waybar/scripts/weather.py, refreshed every 15 min), so the
// drawer always matches the bar without fetching anything itself.
Singleton {
    id: root

    readonly property bool available: data.text !== undefined && data.text !== ""
    readonly property bool stale: data["class"] === "stale"
    readonly property string icon: available ? data.text.split(" ")[0] : ""
    readonly property string temp: available ? data.text.split(" ").slice(1).join(" ") : ""
    // tooltip: "City: Overcast\nFeels like 72°F\nHigh 68° · Low 58°\n..."
    readonly property var lines: (data.tooltip || "").split("\n")
    readonly property string condition: (lines[0] || "").replace(/^[^:]*:\s*/, "")
    readonly property string highLow: {
        const m = (lines[2] || "").match(/High (\S+) · Low (\S+)/);
        return m ? m[1] + " / " + m[2] : "";
    }

    property var data: ({})

    FileView {
        path: Quickshell.env("HOME") + "/.cache/waybar-weather.json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try { root.data = JSON.parse(text()); } catch (e) { root.data = {}; }
        }
        onLoadFailed: root.data = {}
    }
}
