import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// Dictation pill for voxtype (Right Ctrl push-to-talk, see ~/.config/voxtype/).
//   recording     → capsule with a row of dots that ripple outward with your voice
//   transcribing  → capsule contracts to a squircle while the same dots swirl
//                   into an orbiting ring (the spinner) during STT + LLM cleanup
//   locked mode   → faint blue outline (double-tapped, hands-free)
// Driven by $XDG_RUNTIME_DIR/voxtype/state and live levels from voxtype-audio-bridge.
PanelWindow {
    id: win

    readonly property string runDir: Quickshell.env("XDG_RUNTIME_DIR")
    readonly property color accent: "#61afef"
    property string vstate: "idle"          // voxtype daemon state
    property bool locked: false             // ptt.sh lock state
    readonly property bool active: vstate === "recording" || vstate === "transcribing" || vstate === "streaming"
    readonly property bool listening: vstate === "recording" || vstate === "streaming"
    readonly property bool working: vstate === "transcribing"
    // Capsule/row only while listening; otherwise squircle/ring (so it grows out of one and fades as one)
    readonly property bool contracted: !listening

    readonly property int dots: 9
    readonly property int center: (dots - 1) / 2
    readonly property real restH: 4
    readonly property real maxH: 18
    readonly property real pitch: 9         // row spacing, center to center
    readonly property real ringR: 9         // spinner radius
    // Recent smoothed levels, newest first; dot i shows levels[|i - center|] so sound ripples outward.
    property var levels: [0, 0, 0, 0, 0]

    visible: active || pill.opacity > 0.01
    anchors.bottom: true
    margins.bottom: 44
    exclusionMode: ExclusionMode.Ignore
    implicitWidth: 140
    implicitHeight: 52
    color: "transparent"
    mask: Region {}                          // click-through
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-dictation"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // ── state sources ──
    FileView {
        path: win.runDir + "/voxtype/state"
        watchChanges: true
        printErrors: false
        onLoaded: win.vstate = (text() || "idle").trim()
        onLoadFailed: win.vstate = "idle"
        onFileChanged: reload()
    }
    FileView {
        path: win.runDir + "/voxtype-ptt/state"
        watchChanges: true
        printErrors: false
        onLoaded: win.locked = (text() || "").trim() === "locked"
        onLoadFailed: win.locked = false
        onFileChanged: reload()
    }

    // ── level processing (animation only; the audio itself is untouched) ──
    // Frames arrive at ~94/s. Each frame: track the room's noise floor, gate
    // everything under it, then follow the result with fast attack / slow release.
    property real noiseFloor: 0.08          // in sqrt(rms) units; adapts per room
    property real envelope: 0

    function onFrame(rms) {
        const s = Math.sqrt(Math.max(0, rms));
        // Floor drops quickly to quiet moments, creeps up slowly (so speech doesn't drag it up)
        noiseFloor += (s < noiseFloor ? 0.05 : 0.002) * (s - noiseFloor);
        const gate = Math.max(0.10, noiseFloor * 1.35 + 0.03);
        const target = Math.min(1, Math.max(0, s - gate) * 3.0);
        envelope += (target > envelope ? 0.35 : 0.06) * (target - envelope);
    }

    Process {
        id: bridge
        command: ["voxtype-audio-bridge"]
        running: true
        stdout: SplitParser {
            onRead: function (line) {
                if (!win.listening) return;
                let f;
                try { f = JSON.parse(line); } catch (e) { return; }
                if (typeof f.rms === "number") win.onFrame(f.rms);
            }
        }
        onRunningChanged: if (!running) restart.start()
    }
    Timer { id: restart; interval: 1000; onTriggered: bridge.running = true }

    // Push the envelope into the ripple history ~30x/s
    Timer {
        running: win.listening
        interval: 33
        repeat: true
        onTriggered: {
            const e = win.envelope < 0.02 ? 0 : win.envelope;
            win.levels = [e].concat(win.levels.slice(0, win.center));
        }
    }

    onListeningChanged: if (!listening) { levels = [0, 0, 0, 0, 0]; envelope = 0; }

    // ── row ⇄ ring morph ──
    // morph: 0 = row, 1 = ring. Each dot runs its own eased, staggered copy of it.
    property real morph: contracted ? 1 : 0
    Behavior on morph { NumberAnimation { duration: 560; easing.type: Easing.Linear } }

    // Ring rotation + breathing, ticking only while the ring is (partly) formed
    property real spin: 0
    property real breath: 0
    property real clock: 0
    Timer {
        running: win.visible && win.morph > 0
        interval: 16
        repeat: true
        onTriggered: {
            win.clock += 0.016;
            win.spin += 2 * Math.PI * 0.016 / 0.95;          // one orbit per ~0.95s
            win.breath = Math.sin(win.clock * 2 * Math.PI / 1.4); // slow in/out pulse
        }
    }
    // Keep the unwind short: zero the orbit once hidden, and take the shortest way back mid-spin
    onVisibleChanged: if (!visible) spin = 0
    onContractedChanged: if (!contracted) spin = posMod(spin + Math.PI) - Math.PI

    function ease(t) { return t < 0.5 ? 4 * t * t * t : 1 - Math.pow(-2 * t + 2, 3) / 2; }
    function posMod(a) { const m = 2 * Math.PI; return ((a % m) + m) % m; }

    // ── the pill ──
    Rectangle {
        id: pill
        anchors.centerIn: parent
        // Capsule while listening; roomier squircle around the spinner ring
        height: win.contracted ? 42 : 34
        width: win.contracted ? 42 : 108
        radius: win.contracted ? 15 : height / 2
        Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on width { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 1.2 } }
        Behavior on radius { NumberAnimation { duration: 380; easing.type: Easing.OutCubic } }

        color: "#ee0b0c0f"
        border.width: 1
        border.color: win.locked && win.listening ? Qt.rgba(0.38, 0.69, 0.94, 0.45) : Qt.rgba(1, 1, 1, 0.07)
        Behavior on border.color { ColorAnimation { duration: 200 } }

        opacity: win.active ? 1 : 0
        scale: win.active ? 1 : 0.9
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 240; easing.type: Easing.OutCubic } }

        Repeater {
            model: win.dots

            Rectangle {
                id: dot
                required property int index
                readonly property real d: (index - win.center) * win.pitch       // row offset from center
                readonly property int dist: Math.abs(index - win.center)
                readonly property real taper: 1 - dist * 0.13
                readonly property real lvl: win.listening ? (win.levels[dist] || 0) : 0

                // Staggered progress: outer dots leave first (the capsule edge is closing in on them).
                // Radius converges early (ease-out) so dots pull inward first, then rotate into their slots.
                readonly property real p: Math.min(1, Math.max(0, win.morph * 1.45 - (win.center - dist) * 0.1))
                readonly property real e: win.ease(p)
                readonly property real er: 1 - Math.pow(1 - p, 3)

                // Polar path: start on the row (angle 0 right / π left, radius |d|),
                // swirl clockwise into an evenly spaced ring slot, then orbit.
                readonly property real a0: index > win.center ? 0 : (index < win.center ? Math.PI : Math.PI / 2)
                readonly property real a1: -Math.PI / 2 + index * 2 * Math.PI / win.dots
                readonly property real swirl: win.posMod(a1 - a0)
                readonly property real ang: a0 + e * (swirl + win.spin)
                readonly property real rad: Math.abs(d) + er * (win.ringR * (1 + 0.08 * win.breath) - Math.abs(d))

                // Row: bar height follows the voice. Ring: small round dots with a comet tail.
                readonly property real rowH: win.restH + (win.maxH - win.restH) * lvl * taper
                readonly property real ringSize: 3.2 + 1.3 * (index / (win.dots - 1))
                width: 4 + e * (ringSize - 4)
                height: rowH + e * (ringSize - rowH)
                radius: width / 2
                Behavior on height { enabled: dot.e === 0; NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }

                x: pill.width / 2 + rad * Math.cos(ang) - width / 2
                y: pill.height / 2 + rad * Math.sin(ang) - height / 2

                color: win.accent
                opacity: {
                    const rowOp = 0.7 + 0.3 * lvl;
                    const ringOp = 0.18 + 0.82 * Math.pow(index / (win.dots - 1), 1.6);
                    return rowOp + e * (ringOp - rowOp);
                }
            }
        }
    }
}
