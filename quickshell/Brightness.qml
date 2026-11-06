pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen brightness via brightnessctl, using the same exponent (-e4) as the
// waybar module and keybinds so the percentages agree.
Singleton {
    id: root

    property real value: 0  // 0..1

    function refresh() { reader.running = true; }

    function set(v) {
        value = Math.max(0.01, Math.min(1, v));
        pending = Math.round(value * 100);
        if (!writer.running) flush();
    }

    property int pending: -1
    function flush() {
        if (pending < 0) return;
        writer.command = ["sh", "-c", `brightnessctl -d intel_backlight -e4 -n1 set ${pending}% >/dev/null && pkill -RTMIN+8 waybar`];
        pending = -1;
        writer.running = true;
    }

    Process {
        id: reader
        command: ["brightnessctl", "-d", "intel_backlight", "-e4", "-m"]
        stdout: StdioCollector {
            onStreamFinished: {
                const pct = parseInt(text.split(",")[3]);
                if (!isNaN(pct)) root.value = pct / 100;
            }
        }
    }

    // Drags fire faster than brightnessctl runs; only the latest value is
    // applied once the previous write finishes.
    Process {
        id: writer
        onExited: root.flush()
    }
}
