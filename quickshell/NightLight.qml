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

    // User actions: these cancel an in-progress evening fade.
    function setOn(v) { state.fading = false; state.on = v; apply(); }
    function setTemperature(k) {
        state.fading = false;
        state.temperature = Math.round(Math.max(minTemp, Math.min(maxTemp, k)) / 50) * 50;
        state.on = true;
        apply();
    }

    function apply() {
        Quickshell.execDetached(state.on
            ? ["hyprctl", "hyprsunset", "temperature", String(state.temperature)]
            : ["hyprctl", "hyprsunset", "identity"]);
    }

    // Schedule (minutes since midnight): fades in from neutral at 21:00,
    // reaching fadeTarget at 22:00, and turns off at 07:00. It only acts when
    // crossing a boundary, so manual changes in between stick.
    readonly property int scheduleStart: 21 * 60
    readonly property int fadeEnd: 22 * 60
    readonly property int scheduleEnd: 7 * 60
    readonly property int fadeFrom: 6500   // ~neutral, so the fade starts invisibly
    readonly property int fadeTarget: 2900

    function minutesNow() {
        const d = new Date();
        return d.getHours() * 60 + d.getMinutes() + d.getSeconds() / 60;
    }

    function inSchedule() {
        const m = minutesNow();
        return scheduleStart > scheduleEnd
            ? (m >= scheduleStart || m < scheduleEnd)
            : (m >= scheduleStart && m < scheduleEnd);
    }

    // Where on the fade curve we are right now (0 = start, 1 = done).
    function fadeProgress() {
        let elapsed = minutesNow() - scheduleStart;
        if (elapsed < 0) elapsed += 24 * 60;
        return Math.min(1, elapsed / (fadeEnd - scheduleStart));
    }

    function stepFade() {
        const p = fadeProgress();
        state.temperature = Math.round(fadeFrom + (fadeTarget - fadeFrom) * p);
        state.on = true;
        if (p >= 1) state.fading = false;
        apply();
    }

    function checkSchedule() {
        const s = inSchedule() ? 1 : 0;
        if (s !== state.scheduleState) {
            state.scheduleState = s;
            if (s === 1) {
                // Entering the window: start the fade at the curve's current
                // point (straight to fadeTarget if it's already past fadeEnd).
                state.fading = true;
                stepFade();
            } else {
                setOn(false);
            }
        }
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.checkSchedule()
    }

    // Small frequent steps while fading (~4K each) so the change is smooth.
    Timer {
        interval: 5000
        running: state.fading
        repeat: true
        onTriggered: root.stepFade()
    }

    PersistentProperties {
        id: state
        reloadableId: "nightlight"
        property bool on: false
        property int temperature: 4000
        // Last schedule window seen (-1 = none yet, so the first check applies it)
        property int scheduleState: -1
        property bool fading: false
        // Push our state to hyprsunset on start (default: off) and after
        // reloads; re-applying an unchanged state is harmless.
        onLoaded: root.apply()
    }
}
