pragma Singleton
import QtQuick
import Quickshell

// One Dark, matching waybar/mako.
Singleton {
    readonly property color bg: "#282c34"
    readonly property color bgAlpha: "#f2282c34"
    readonly property color surface: "#2f343f"
    readonly property color surfaceHover: "#363c48"
    readonly property color border: "#3e4452"
    readonly property color text: "#abb2bf"
    readonly property color textBright: "#d7dae0"
    readonly property color muted: "#5c6370"
    readonly property color blue: "#61afef"
    readonly property color magenta: "#c678dd"
    readonly property color red: "#e06c75"
    readonly property color green: "#98c379"
    readonly property color yellow: "#e5c07b"

    readonly property string font: "RecMonoLinear Nerd Font Propo"
    readonly property int radius: 14
}
