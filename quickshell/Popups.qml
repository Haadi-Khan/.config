import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications

// On-screen notification popups, top-right (where mako used to put them).
PanelWindow {
    id: win

    visible: Notifs.popups.length > 0 && Panels.current !== "drawer"
    anchors { top: true; right: true }
    margins { top: 12; right: 12 }
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: 0
    implicitWidth: 380
    implicitHeight: Math.max(1, stack.implicitHeight)
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"

    Column {
        id: stack
        width: parent.width
        spacing: 10

        Repeater {
            model: Notifs.popups

            NotifCard {
                id: card
                required property Notification modelData
                notif: modelData
                popup: true
                width: stack.width

                // Popups disappear after their timeout but stay in the drawer.
                // expireTimeout is in ms; <= 0 means "use the default".
                readonly property int timeout: {
                    if (critical) return 0;
                    if (notif.expireTimeout > 0) return notif.expireTimeout;
                    return notif.urgency === NotificationUrgency.Low ? 4000 : 6000;
                }

                Timer {
                    running: card.timeout > 0 && !card.hovered
                    interval: card.timeout
                    onTriggered: Notifs.removePopup(card.notif)
                }

                opacity: 0
                transform: Translate { id: slide; x: 40 }
                Component.onCompleted: enter.start()
                ParallelAnimation {
                    id: enter
                    NumberAnimation { target: card; property: "opacity"; to: 1; duration: 180; easing.type: Easing.OutCubic }
                    NumberAnimation { target: slide; property: "x"; to: 0; duration: 220; easing.type: Easing.OutCubic }
                }
            }
        }
    }
}
