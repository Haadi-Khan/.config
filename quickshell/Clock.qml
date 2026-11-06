pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property date now: clock.date

    function relative(t) {
        const s = Math.max(0, (now - t) / 1000);
        if (s < 60) return "now";
        if (s < 3600) return Math.floor(s / 60) + "m ago";
        if (s < 86400) return Math.floor(s / 3600) + "h ago";
        return Qt.formatDate(t, "MMM d");
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
}
