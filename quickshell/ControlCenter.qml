import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Networking
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

// GNOME-style quick settings that drop down under the right waybar island.
PanelWindow {
    id: win

    visible: Panels.current === "control"
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-control"
    // Take keyboard focus (for Esc / typing) only while the pointer is over
    // the panel. Grabbing focus on open makes Hyprland route the next click
    // to this window, so clicking the bar island again wouldn't close it.
    WlrLayershell.keyboardFocus: panelHover.hovered ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // Which expandable section is open: "", wifi, bt, power, night, tailscale, audio, session.
    property string menu: ""
    function toggleMenu(name) { menu = menu === name ? "" : name; }
    function run(cmd) { Quickshell.execDetached(cmd); }

    //   qs ipc call control toggle
    //   qs ipc call control menu wifi|bt|power|night|tailscale|audio|session
    IpcHandler {
        target: "control"
        function toggle(): void { Panels.toggle("control"); }
        function open(): void { Panels.open("control"); }
        function close(): void { Panels.close(); }
        function menu(name: string): void { Panels.open("control"); win.menu = name; }
    }

    // The window covers the screen below the bar; clicking anywhere outside
    // the panel closes it. The bar itself stays clickable, so clicking its
    // island again closes the panel (or the other island switches panels).
    // (A Hyprland focus grab would swallow those bar clicks instead.)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: Panels.close()
    }

    onVisibleChanged: if (visible) {
        menu = "";
        pskFor = "";
        wifiError = "";
        Brightness.refresh();
        openAnim.restart();
    }

    // ── Audio ──
    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource
    PwObjectTracker { objects: [win.sink, win.source] }
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    function nodeName(n) { return n ? (n.description || n.nickname || n.name) : ""; }

    // ── Wi-Fi ──
    readonly property var wifiDev: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: wifiDev
        ? wifiDev.networks.values.filter(n => n.name)
              .sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength))
        : []
    readonly property var activeNetwork: networks.find(n => n.connected) ?? null
    property string pskFor: ""
    property string wifiError: ""
    function signalIcon(s) {
        const icons = ["󰤯", "󰤟", "󰤢", "󰤥", "󰤨"];
        return icons[Math.max(0, Math.min(4, Math.round(s * 4)))];
    }
    function secured(n) { return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe; }
    Binding {
        when: win.menu === "wifi" && win.wifiDev !== null
        target: win.wifiDev; property: "scannerEnabled"; value: true
    }

    // ── Bluetooth ──
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: adapter?.enabled ?? false
    readonly property var btDevices: adapter
        ? adapter.devices.values
              .filter(d => d.paired || d.connected)
              .sort((a, b) => (b.connected - a.connected) || a.name.localeCompare(b.name))
        : []
    // Unpaired devices found while scanning, limited to the kinds people
    // actually pair (skips printers, TVs, other people's laptops, ...).
    readonly property var btNearby: adapter && win.menu === "bt"
        ? adapter.devices.values
              .filter(d => !d.paired && !d.connected && /audio|headset|headphone|speaker|input|phone|gaming/.test(d.icon || ""))
              .slice(0, 5)
        : []
    readonly property var btConnected: btDevices.filter(d => d.connected)
    function btIcon(d) {
        const i = d.icon || "";
        if (i.includes("headset") || i.includes("headphone")) return "󰋋";
        if (i.includes("audio") || i.includes("speaker")) return "󰓃";
        if (i.includes("keyboard")) return "󰌌";
        if (i.includes("mouse")) return "󰍽";
        if (i.includes("phone")) return "󰟲";
        if (i.includes("gaming") || i.includes("joystick")) return "󰊵";
        return "󰂯";
    }
    Binding {
        when: win.menu === "bt" && win.btOn
        target: win.adapter; property: "discovering"; value: true
    }

    // ── Power profiles ──
    readonly property var profiles: [
        { id: PowerProfile.PowerSaver, name: "Power Saver", icon: "󰌪" },
        { id: PowerProfile.Balanced, name: "Balanced", icon: "" },
        { id: PowerProfile.Performance, name: "Performance", icon: "󱐋" },
    ].filter(p => p.id !== PowerProfile.Performance || PowerProfiles.hasPerformanceProfile)
    readonly property var currentProfile: profiles.find(p => p.id === PowerProfiles.profile) ?? profiles[1]

    // ── Caffeine: hold an idle inhibitor, which hypridle respects ──
    Process {
        id: caffeine
        command: ["systemd-inhibit", "--what=idle", "--who=Quickshell", "--why=Caffeine", "sleep", "infinity"]
    }

    // ── Battery ──
    readonly property var battery: UPower.displayDevice
    function duration(sec) {
        const h = Math.floor(sec / 3600), m = Math.round((sec % 3600) / 60);
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    Rectangle {
        id: panel
        x: parent.width - width - 8
        y: 6
        width: 400
        height: content.implicitHeight + 32
        radius: Theme.radius
        color: Theme.bg
        border { width: 2; color: Theme.border }
        focus: true
        Keys.onEscapePressed: win.menu !== "" ? win.menu = "" : Panels.close()
        HoverHandler { id: panelHover }
        // Swallow clicks on the panel's own background.
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

        transform: Translate { id: drop; y: 0 }
        ParallelAnimation {
            id: openAnim
            NumberAnimation { target: panel; property: "opacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
            NumberAnimation { target: drop; property: "y"; from: -16; to: 0; duration: 220; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: content
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            spacing: 12

            // ── Header: battery + lock/power ──
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Rectangle {
                    visible: win.battery?.isLaptopBattery ?? false
                    implicitHeight: 36
                    implicitWidth: batteryText.implicitWidth + 28
                    radius: 18
                    color: Theme.surface
                    Text {
                        id: batteryText
                        anchors.centerIn: parent
                        readonly property real pct: Math.round((win.battery?.percentage ?? 0) * 100)
                        readonly property bool charging: win.battery?.state === UPowerDeviceState.Charging
                        readonly property bool full: win.battery?.state === UPowerDeviceState.FullyCharged
                        text: {
                            const icons = ["", "", "", "", ""];
                            const icon = charging ? "󰂄" : icons[Math.min(4, Math.floor(pct / 20))];
                            let t = `${icon}  ${pct}%`;
                            if (charging && win.battery.timeToFull > 0) t += `  ·  full in ${win.duration(win.battery.timeToFull)}`;
                            else if (!charging && !full && win.battery.timeToEmpty > 0) t += `  ·  ${win.duration(win.battery.timeToEmpty)} left`;
                            return t;
                        }
                        color: pct <= 15 && !charging ? Theme.red : Theme.green
                        font { family: Theme.font; pixelSize: 12 }
                    }
                }

                Item { Layout.fillWidth: true }

                RoundButton {
                    glyph: ""
                    onClicked: { Panels.close(); win.run(["loginctl", "lock-session"]); }
                }
                RoundButton {
                    glyph: ""
                    highlighted: win.menu === "session"
                    onClicked: win.toggleMenu("session")
                }
            }

            // Session menu (power button)
            Menu {
                shown: win.menu === "session"
                ColumnLayout {
                    id: session
                    Layout.fillWidth: true
                    spacing: 2
                    property string armed: ""
                    Timer { id: disarm; interval: 3000; onTriggered: session.armed = "" }
                    onVisibleChanged: armed = ""

                    Repeater {
                        model: [
                            { key: "suspend", label: "Suspend", icon: "󰤄", confirm: false, cmd: ["systemctl", "suspend"] },
                            { key: "logout", label: "Log Out", icon: "󰍃", confirm: true, cmd: ["hyprctl", "dispatch", "hl.dsp.exit()"] },
                            { key: "reboot", label: "Restart", icon: "󰑓", confirm: true, cmd: ["systemctl", "reboot"] },
                            { key: "poweroff", label: "Shut Down", icon: "", confirm: true, cmd: ["systemctl", "poweroff"] },
                        ]
                        MenuItem {
                            required property var modelData
                            readonly property bool armed: session.armed === modelData.key
                            icon: modelData.icon
                            label: armed ? `Click again to ${modelData.label.toLowerCase()}` : modelData.label
                            accent: armed ? Theme.red : Theme.text
                            onClicked: {
                                if (modelData.confirm && !armed) { session.armed = modelData.key; disarm.restart(); return; }
                                Panels.close();
                                win.run(modelData.cmd);
                            }
                        }
                    }
                }
            }

            // ── Sliders ──
            SliderRow {
                Layout.fillWidth: true
                readonly property real vol: win.sink?.audio?.volume ?? 0
                readonly property bool muted: win.sink?.audio?.muted ?? true
                icon: muted ? "󰖁" : vol < 0.34 ? "󰕿" : vol < 0.67 ? "󰖀" : "󰕾"
                value: vol
                dimmed: muted
                hasMenu: true
                menuOpen: win.menu === "audio"
                onMoved: v => { if (win.sink?.audio) { win.sink.audio.muted = false; win.sink.audio.volume = v; } }
                onIconClicked: if (win.sink?.audio) win.sink.audio.muted = !win.sink.audio.muted
                onMenuRequested: win.toggleMenu("audio")
            }

            Menu {
                shown: win.menu === "audio"
                title: "Sound Output"
                Repeater {
                    model: win.sinks
                    MenuItem {
                        required property PwNode modelData
                        icon: "󰓃"
                        label: win.nodeName(modelData)
                        checked: modelData === win.sink
                        onClicked: Pipewire.preferredDefaultAudioSink = modelData
                    }
                }
                MenuItem {
                    icon: ""
                    label: "Sound Settings"
                    accent: Theme.muted
                    onClicked: { Panels.close(); win.run(["pavucontrol"]); }
                }
            }

            SliderRow {
                Layout.fillWidth: true
                icon: Brightness.value < 0.34 ? "󰃞" : Brightness.value < 0.67 ? "󰃟" : "󰃠"
                value: Brightness.value
                onMoved: v => Brightness.set(v)
            }

            // ── Quick toggles ──
            GridLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                columns: 2
                rowSpacing: 10
                columnSpacing: 10

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: !Networking.wifiEnabled ? "󰤮" : win.activeNetwork ? win.signalIcon(win.activeNetwork.signalStrength) : "󰤯"
                    label: "Wi-Fi"
                    sublabel: !Networking.wifiEnabled ? "Off" : win.activeNetwork ? win.activeNetwork.name : "Not connected"
                    active: Networking.wifiEnabled
                    hasMenu: true
                    menuOpen: win.menu === "wifi"
                    onToggled: Networking.wifiEnabled = !Networking.wifiEnabled
                    onMenuRequested: win.toggleMenu("wifi")
                }

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: !win.btOn ? "󰂲" : win.btConnected.length ? "󰂱" : "󰂯"
                    label: "Bluetooth"
                    sublabel: !win.btOn ? "Off" : win.btConnected.length === 1 ? win.btConnected[0].name
                        : win.btConnected.length > 1 ? `${win.btConnected.length} devices` : "On"
                    active: win.btOn
                    hasMenu: true
                    menuOpen: win.menu === "bt"
                    onToggled: if (win.adapter) win.adapter.enabled = !win.adapter.enabled
                    onMenuRequested: win.toggleMenu("bt")
                }

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: win.currentProfile.icon
                    label: "Power Mode"
                    sublabel: win.currentProfile.name
                    active: PowerProfiles.profile !== PowerProfile.Balanced
                    hasMenu: true
                    menuOpen: win.menu === "power"
                    onToggled: win.toggleMenu("power")
                    onMenuRequested: win.toggleMenu("power")
                }

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    readonly property bool muted: win.source?.audio?.muted ?? true
                    icon: muted ? "󰍭" : "󰍬"
                    label: "Microphone"
                    sublabel: muted ? "Muted" : "On"
                    active: !muted
                    onToggled: if (win.source?.audio) win.source.audio.muted = !win.source.audio.muted
                }

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: NightLight.on ? "\udb81\udd94" : "\udb81\udd99"
                    label: "Night Light"
                    sublabel: NightLight.on ? `${NightLight.temperature}K` : "Off"
                    active: NightLight.on
                    hasMenu: true
                    menuOpen: win.menu === "night"
                    onToggled: NightLight.setOn(!NightLight.on)
                    onMenuRequested: win.toggleMenu("night")
                }

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: Notifs.dnd ? "󰂛" : "󰂚"
                    label: "Do Not Disturb"
                    sublabel: Notifs.dnd ? "On" : "Off"
                    active: Notifs.dnd
                    onToggled: Notifs.dnd = !Notifs.dnd
                }

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    icon: "󰅶"
                    label: "Caffeine"
                    sublabel: caffeine.running ? "Staying awake" : "Off"
                    active: caffeine.running
                    onToggled: caffeine.running = !caffeine.running
                }

                QuickToggle {
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                    visible: Tailscale.available
                    icon: "\udb81\udd82"
                    label: "Tailscale"
                    sublabel: Tailscale.busy ? (Tailscale.connected ? "Disconnecting…" : "Connecting…")
                        : Tailscale.error === "operator" ? "Needs operator access"
                        : Tailscale.error ? Tailscale.error
                        : Tailscale.connected ? (Tailscale.exitNode ? Tailscale.place(Tailscale.exitNode) : (Tailscale.tailnet || "Connected"))
                        : Tailscale.state === "NeedsLogin" ? "Logged out" : "Off"
                    active: Tailscale.connected
                    hasMenu: true
                    menuOpen: win.menu === "tailscale"
                    onToggled: Tailscale.toggle()
                    onMenuRequested: win.toggleMenu("tailscale")
                }
            }

            // Wi-Fi menu
            Menu {
                shown: win.menu === "wifi"
                title: "Wi-Fi Networks"
                busy: win.wifiDev?.scannerEnabled ?? false

                Text {
                    Layout.fillWidth: true
                    Layout.margins: 8
                    visible: !Networking.wifiEnabled || win.networks.length === 0
                    text: !Networking.wifiEnabled ? "Wi-Fi is off" : "Searching…"
                    color: Theme.muted
                    font { family: Theme.font; pixelSize: 12 }
                }

                Repeater {
                    model: Networking.wifiEnabled ? win.networks.slice(0, 10) : []
                    ColumnLayout {
                        id: netRow
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 2

                        Connections {
                            target: netRow.modelData
                            function onConnectionFailed(reason) {
                                win.wifiError = `Couldn't connect to ${netRow.modelData.name}`;
                                if (reason === ConnectionFailReason.NoSecrets) win.pskFor = netRow.modelData.name;
                            }
                        }

                        MenuItem {
                            Layout.fillWidth: true
                            icon: win.signalIcon(netRow.modelData.signalStrength)
                            label: netRow.modelData.name
                            detail: netRow.modelData.stateChanging ? "Connecting…" : (win.secured(netRow.modelData) ? "" : "")
                            checked: netRow.modelData.connected
                            onClicked: {
                                const n = netRow.modelData;
                                win.wifiError = "";
                                if (n.connected) n.disconnect();
                                else if (n.known || !win.secured(n)) n.connect();
                                else win.pskFor = win.pskFor === n.name ? "" : n.name;
                            }
                        }

                        // Password entry for new secured networks
                        Rectangle {
                            visible: win.pskFor === netRow.modelData.name
                            Layout.fillWidth: true
                            Layout.leftMargin: 8
                            Layout.rightMargin: 8
                            implicitHeight: 34
                            radius: 8
                            color: Theme.bg
                            border { width: 1; color: psk.activeFocus ? Theme.blue : Theme.border }
                            onVisibleChanged: if (visible) { psk.text = ""; psk.forceActiveFocus(); }

                            TextInput {
                                id: psk
                                anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: TextInput.Password
                                color: Theme.text
                                selectionColor: Theme.blue
                                font { family: Theme.font; pixelSize: 12 }
                                Keys.onEscapePressed: win.pskFor = ""
                                onAccepted: {
                                    netRow.modelData.connectWithPsk(text);
                                    win.pskFor = "";
                                }
                                Text {
                                    visible: !psk.text
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Password — press Enter to connect"
                                    color: Theme.muted
                                    font: psk.font
                                }
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    visible: win.wifiError !== ""
                    text: win.wifiError
                    color: Theme.red
                    font { family: Theme.font; pixelSize: 11 }
                }

                MenuItem {
                    icon: ""
                    label: "Network Settings"
                    accent: Theme.muted
                    onClicked: { Panels.close(); win.run(["ghostty", "-e", "nmtui"]); }
                }
            }

            // Bluetooth menu
            Menu {
                shown: win.menu === "bt"
                title: "Bluetooth Devices"
                busy: win.adapter?.discovering ?? false

                Text {
                    Layout.fillWidth: true
                    Layout.margins: 8
                    visible: !win.btOn || win.btDevices.length === 0
                    text: !win.btOn ? "Bluetooth is off" : "No paired devices"
                    color: Theme.muted
                    font { family: Theme.font; pixelSize: 12 }
                }

                Repeater {
                    model: win.btOn ? win.btDevices.concat(win.btNearby) : []
                    MenuItem {
                        required property BluetoothDevice modelData
                        readonly property bool busy: modelData.pairing
                            || modelData.state === BluetoothDeviceState.Connecting
                            || modelData.state === BluetoothDeviceState.Disconnecting
                        icon: win.btIcon(modelData)
                        label: modelData.name
                        detail: busy ? "…" : modelData.connected && modelData.batteryAvailable
                            ? `${Math.round(modelData.battery * 100)}%` : !modelData.paired ? "Pair" : ""
                        checked: modelData.connected
                        onClicked: {
                            const d = modelData;
                            if (d.connected) d.disconnect();
                            else if (d.paired) d.connect();
                            else { d.trusted = true; d.pair(); }
                        }
                    }
                }
            }

            // Night light menu: warmth slider (right = warmer)
            Menu {
                shown: win.menu === "night"
                title: "Night Light"
                SliderRow {
                    Layout.fillWidth: true
                    Layout.leftMargin: 4
                    Layout.rightMargin: 4
                    icon: "\udb81\udd94"
                    dimmed: !NightLight.on
                    value: (NightLight.maxTemp - NightLight.temperature) / (NightLight.maxTemp - NightLight.minTemp)
                    onMoved: v => NightLight.setTemperature(NightLight.maxTemp - v * (NightLight.maxTemp - NightLight.minTemp))
                    onIconClicked: NightLight.setOn(!NightLight.on)
                }
            }

            // Tailscale exit node menu: Direct / Suggested / country → city
            Menu {
                id: tsMenu
                shown: win.menu === "tailscale"
                title: tsCountry ? `${Tailscale.flag(tsCountryCode)}  ${tsCountry}` : "Exit Node"
                busy: Tailscale.switching

                property string tsCountry: ""
                property string tsCountryCode: ""
                onShownChanged: if (shown) { tsCountry = ""; Tailscale.suggest(); Tailscale.refresh(); }

                readonly property var suggestedNode: Tailscale.nodeByName(Tailscale.suggested)
                readonly property var current: Tailscale.exitNode
                readonly property var cities: tsCountry
                    ? (Tailscale.countries.find(c => c.country === tsCountry)?.cities ?? []) : []

                Text {
                    Layout.fillWidth: true
                    Layout.margins: 8
                    visible: !Tailscale.connected
                    text: "Connect Tailscale to use an exit node"
                    color: Theme.muted
                    font { family: Theme.font; pixelSize: 12 }
                }

                // ── Top level ──
                MenuItem {
                    visible: Tailscale.connected && !tsMenu.tsCountry
                    icon: "\uf0ac"
                    label: "Direct (no exit node)"
                    checked: !tsMenu.current
                    onClicked: Tailscale.setExitNode("")
                }
                MenuItem {
                    visible: Tailscale.connected && !tsMenu.tsCountry && tsMenu.suggestedNode !== null
                    icon: "\uf005"
                    label: "Suggested: " + Tailscale.place(tsMenu.suggestedNode)
                    checked: tsMenu.current !== null && tsMenu.current.name === Tailscale.suggested
                    onClicked: Tailscale.setExitNode(Tailscale.suggested)
                }

                ListView {
                    id: countryList
                    visible: Tailscale.connected && !tsMenu.tsCountry
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(260, contentHeight)
                    clip: true
                    spacing: 2
                    boundsBehavior: Flickable.StopAtBounds
                    model: Tailscale.countries
                    WheelScroll { flickable: countryList }
                    delegate: MenuItem {
                        required property var modelData
                        width: ListView.view.width
                        icon: Tailscale.flag(modelData.countryCode)
                        label: modelData.country
                        checked: tsMenu.current !== null && tsMenu.current.country === modelData.country
                        detail: modelData.cities.length > 1 ? `${modelData.cities.length} cities  \uf054` : ""
                        onClicked: {
                            if (modelData.cities.length > 1) {
                                tsMenu.tsCountry = modelData.country;
                                tsMenu.tsCountryCode = modelData.countryCode;
                            } else {
                                const n = Tailscale.bestNode(modelData.country, "");
                                if (n) Tailscale.setExitNode(n.name);
                            }
                        }
                    }
                }

                // ── Inside a country ──
                MenuItem {
                    visible: !!tsMenu.tsCountry
                    icon: "\uf053"
                    label: "All countries"
                    accent: Theme.muted
                    onClicked: tsMenu.tsCountry = ""
                }
                MenuItem {
                    visible: !!tsMenu.tsCountry
                    icon: "\uf0ac"
                    label: "Fastest in " + tsMenu.tsCountry
                    onClicked: {
                        const n = Tailscale.bestNode(tsMenu.tsCountry, "");
                        if (n) Tailscale.setExitNode(n.name);
                    }
                }
                ListView {
                    id: cityList
                    visible: !!tsMenu.tsCountry
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(260, contentHeight)
                    clip: true
                    spacing: 2
                    boundsBehavior: Flickable.StopAtBounds
                    model: tsMenu.cities
                    WheelScroll { flickable: cityList }
                    delegate: MenuItem {
                        required property string modelData
                        width: ListView.view.width
                        icon: "\uf3c5"
                        label: modelData
                        checked: tsMenu.current !== null && tsMenu.current.country === tsMenu.tsCountry && tsMenu.current.city === modelData
                        onClicked: {
                            const n = Tailscale.bestNode(tsMenu.tsCountry, modelData);
                            if (n) Tailscale.setExitNode(n.name);
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    Layout.leftMargin: 8
                    visible: Tailscale.error !== "" && Tailscale.error !== "operator"
                    text: Tailscale.error
                    color: Theme.red
                    wrapMode: Text.Wrap
                    font { family: Theme.font; pixelSize: 11 }
                }
            }

            // Power mode menu
            Menu {
                shown: win.menu === "power"
                title: "Power Mode"
                Repeater {
                    model: win.profiles
                    MenuItem {
                        required property var modelData
                        icon: modelData.icon
                        label: modelData.name
                        checked: PowerProfiles.profile === modelData.id
                        onClicked: PowerProfiles.profile = modelData.id
                    }
                }
            }
        }
    }

    // ── Small building blocks ──

    component RoundButton: Rectangle {
        property string glyph
        property bool highlighted: false
        signal clicked
        implicitWidth: 36; implicitHeight: 36; radius: 18
        color: highlighted ? Theme.blue : (area.containsMouse ? Theme.surfaceHover : Theme.surface)
        Text {
            anchors.centerIn: parent
            text: parent.glyph
            color: parent.highlighted ? Theme.bg : Theme.text
            font { family: Theme.font; pixelSize: 14 }
        }
        MouseArea {
            id: area
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }

    // Expandable section card.
    component Menu: Rectangle {
        property bool shown: false
        property string title: ""
        property bool busy: false
        default property alias items: menuCol.data

        visible: shown
        Layout.fillWidth: true
        implicitHeight: menuCol.implicitHeight + 16
        radius: 12
        color: Theme.surface

        ColumnLayout {
            id: menuCol
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
            spacing: 2

            RowLayout {
                visible: parent.parent.title !== ""
                Layout.fillWidth: true
                Layout.margins: 6
                Text {
                    Layout.fillWidth: true
                    text: menuCol.parent.title
                    color: Theme.textBright
                    font { family: Theme.font; pixelSize: 13; bold: true }
                }
                Text {
                    visible: menuCol.parent.busy
                    text: ""
                    color: Theme.muted
                    font { family: Theme.font; pixelSize: 12 }
                    RotationAnimation on rotation { running: visible; loops: Animation.Infinite; from: 0; to: 360; duration: 1200 }
                }
            }
        }
    }

    component MenuItem: Rectangle {
        property string icon
        property string label
        property string detail: ""
        property bool checked: false
        property color accent: Theme.text
        signal clicked

        Layout.fillWidth: true
        implicitHeight: 36
        radius: 8
        color: itemArea.containsMouse ? Theme.surfaceHover : "transparent"

        RowLayout {
            anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
            spacing: 10
            Text {
                Layout.preferredWidth: 18
                horizontalAlignment: Text.AlignHCenter
                text: parent.parent.icon
                color: parent.parent.checked ? Theme.blue : parent.parent.accent
                font { family: Theme.font; pixelSize: 14 }
            }
            Text {
                Layout.fillWidth: true
                text: parent.parent.label
                color: parent.parent.checked ? Theme.blue : parent.parent.accent
                font { family: Theme.font; pixelSize: 12; bold: parent.parent.checked }
                elide: Text.ElideRight
            }
            Text {
                visible: text !== ""
                text: parent.parent.detail
                color: Theme.muted
                font { family: Theme.font; pixelSize: 11 }
            }
            Text {
                visible: parent.parent.checked
                text: ""
                color: Theme.blue
                font { family: Theme.font; pixelSize: 12 }
            }
        }
        MouseArea {
            id: itemArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
