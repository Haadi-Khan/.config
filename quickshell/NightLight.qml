pragma Singleton
import QtQuick
import Quickshell

// Night light via hyprsunset's IPC (hyprsunset is started by Hyprland
// autostart). hyprsunset can't report whether it's in identity mode, so the
// on/off state lives here and is pushed to hyprsunset on every change.
Singleton {
    id: root

    readonly property alias on: state.on
    readonly property alias temperature: state.temperature
    readonly property int minTemp: 2500
    readonly property int maxTemp: 5500

    function setOn(v) { state.on = v; apply(); }
    function setTemperature(k) {
        state.temperature = Math.round(Math.max(minTemp, Math.min(maxTemp, k)) / 50) * 50;
        state.on = true;
        apply();
    }

    function apply() {
        Quickshell.execDetached(state.on
            ? ["hyprctl", "hyprsunset", "temperature", String(state.temperature)]
            : ["hyprctl", "hyprsunset", "identity"]);
    }

    PersistentProperties {
        id: state
        reloadableId: "nightlight"
        property bool on: false
        property int temperature: 4000
        // Push our state to hyprsunset on start (default: off) and after
        // reloads; re-applying an unchanged state is harmless.
        onLoaded: root.apply()
    }
}
