import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications

// GNOME-style drawer that drops down under the waybar clock:
// notifications on the left, calendar + agenda on the right.
PanelWindow {
    id: win

    visible: Panels.current === "drawer"
    screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0]
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-drawer"
    // Take keyboard focus (for Esc / typing) only while the pointer is over
    // the panel. Grabbing focus on open makes Hyprland route the next click
    // to this window, so clicking the bar island again wouldn't close it.
    WlrLayershell.keyboardFocus: panelHover.hovered ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    // The window covers the screen below the bar; clicking anywhere outside
    // the panel closes it. The bar itself stays clickable, so clicking its
    // island again closes the panel (or the other island switches panels).
    // (A Hyprland focus grab would swallow those bar clicks instead.)
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        onClicked: Panels.close()
    }

    onVisibleChanged: if (visible) { calendar.reset(); openAnim.restart(); }

    Rectangle {
        id: panel
        x: Math.round((parent.width - width) / 2)
        y: 6
        width: 780
        height: 520
        radius: Theme.radius
        color: Theme.bg
        border { width: 2; color: Theme.border }
        focus: true
        Keys.onEscapePressed: Panels.close()
        HoverHandler { id: panelHover }
        // Swallow clicks on the panel's own background.
        MouseArea { anchors.fill: parent; acceptedButtons: Qt.AllButtons }

        transform: Translate { id: drop; y: 0 }
        ParallelAnimation {
            id: openAnim
            NumberAnimation { target: panel; property: "opacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
            NumberAnimation { target: drop; property: "y"; from: -16; to: 0; duration: 220; easing.type: Easing.OutCubic }
        }

        RowLayout {
            anchors { fill: parent; margins: 16 }
            spacing: 16

            // ── Notifications ──
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                Text {
                    text: "Notifications"
                    color: Theme.textBright
                    font { family: Theme.font; pixelSize: 15; bold: true }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    ListView {
                        id: list
                        anchors.fill: parent
                        clip: true
                        spacing: 8
                        model: Notifs.history
                        WheelScroll { flickable: list }
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: NotifCard {
                            required property Notification modelData
                            notif: modelData
                            width: ListView.view.width
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        visible: Notifs.count === 0
                        spacing: 8
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰂛"
                            color: Theme.border
                            font { family: Theme.font; pixelSize: 56 }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "No Notifications"
                            color: Theme.muted
                            font { family: Theme.font; pixelSize: 14; bold: true }
                        }
                    }
                }

                // Footer: Do Not Disturb + Clear
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    Text {
                        text: "Do Not Disturb"
                        color: Theme.text
                        font { family: Theme.font; pixelSize: 12 }
                    }
                    Rectangle {
                        id: toggle
                        implicitWidth: 40; implicitHeight: 22; radius: 11
                        color: Notifs.dnd ? Theme.blue : Theme.surface
                        Behavior on color { ColorAnimation { duration: 120 } }
                        Rectangle {
                            width: 16; height: 16; radius: 8
                            anchors.verticalCenter: parent.verticalCenter
                            x: Notifs.dnd ? parent.width - width - 3 : 3
                            color: Notifs.dnd ? Theme.bg : Theme.text
                            Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifs.dnd = !Notifs.dnd
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle {
                        visible: Notifs.count > 0
                        implicitWidth: clearText.implicitWidth + 24
                        implicitHeight: 26
                        radius: 13
                        color: clearArea.containsMouse ? Theme.surfaceHover : Theme.surface
                        Text {
                            id: clearText
                            anchors.centerIn: parent
                            text: "Clear"
                            color: Theme.text
                            font { family: Theme.font; pixelSize: 12 }
                        }
                        MouseArea {
                            id: clearArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Notifs.clearAll()
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: Theme.border
            }

            // ── Calendar ──
            CalendarView {
                id: calendar
                Layout.preferredWidth: 300
                Layout.fillHeight: true
            }
        }
    }
}
