pragma Singleton
import QtQuick
import Quickshell

// Which dropdown panel is open: "drawer" (clock), "control" (right island) or "".
Singleton {
    property string current: ""

    function toggle(name) { current = current === name ? "" : name; }
    function open(name) { current = name; }
    function close() { current = ""; }
}
