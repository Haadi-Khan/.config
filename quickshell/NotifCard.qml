import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

// One notification. Used both for on-screen popups and in the drawer list.
Rectangle {
    id: card

    required property Notification notif
    property bool popup: false
    // Exposed so popups can pause their timeout while hovered.
    readonly property bool hovered: hover.hovered

    readonly property bool critical: notif.urgency === NotificationUrgency.Critical
    readonly property string iconSource: {
        // Icon-theme names can arrive via either field; resolve them with a
        // check so unknown names show no icon rather than Qt's checkerboard.
        const img = notif.image;
        if (img && !img.startsWith("image://icon/")) return img;
        const i = img ? img.slice("image://icon/".length) : notif.appIcon;
        if (!i) return "";
        if (i.startsWith("/")) return "file://" + i;
        if (i.includes("://")) return i;
        return Quickshell.iconPath(i, true);
    }

    implicitHeight: content.implicitHeight + 24
    radius: 10
    color: popup ? Theme.bgAlpha : (hover.hovered ? Theme.surfaceHover : Theme.surface)
    border.width: popup || critical ? 2 : 0
    border.color: critical ? Theme.red : Theme.border

    Behavior on color { ColorAnimation { duration: 120 } }

    HoverHandler { id: hover }
    // Left click runs the default action; middle/right click dismisses.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton
        onClicked: e => e.button === Qt.LeftButton ? Notifs.activate(card.notif) : card.notif.dismiss()
    }

    RowLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 12

        Image {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 36
            Layout.preferredHeight: 36
            visible: card.iconSource !== "" && status !== Image.Error
            source: card.iconSource
            sourceSize: Qt.size(72, 72)
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 3

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: {
                        const app = card.notif.appName || "Notification";
                        return card.popup ? app : app + "  ·  " + Clock.relative(Notifs.timeOf(card.notif));
                    }
                    color: Theme.muted
                    font { family: Theme.font; pixelSize: 11 }
                    elide: Text.ElideRight
                }

                Text {
                    text: ""
                    color: closeHover.hovered ? Theme.red : Theme.muted
                    font { family: Theme.font; pixelSize: 13 }
                    opacity: hover.hovered || card.popup ? 1 : 0
                    MouseArea {
                        id: closeHover
                        readonly property alias hovered: closeHover.containsMouse
                        anchors { fill: parent; margins: -4 }
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: card.notif.dismiss()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.notif.summary
                color: card.critical ? Theme.red : Theme.blue
                font { family: Theme.font; pixelSize: 13; bold: true }
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: card.notif.body
                textFormat: Text.StyledText
                color: Theme.text
                linkColor: Theme.blue
                font { family: Theme.font; pixelSize: 12 }
                wrapMode: Text.Wrap
                maximumLineCount: card.popup ? 4 : 8
                elide: Text.ElideRight
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 6
                visible: actionRepeater.count > 0

                Repeater {
                    id: actionRepeater
                    model: card.notif.actions.filter(a => a.identifier !== "default" && a.text)

                    Rectangle {
                        required property NotificationAction modelData
                        implicitWidth: actionText.implicitWidth + 20
                        implicitHeight: actionText.implicitHeight + 10
                        radius: 6
                        color: actionHover.hovered ? Theme.border : Theme.bg

                        Text {
                            id: actionText
                            anchors.centerIn: parent
                            text: parent.modelData.text
                            color: Theme.text
                            font { family: Theme.font; pixelSize: 11 }
                        }
                        MouseArea {
                            id: actionHover
                            readonly property alias hovered: actionHover.containsMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: parent.modelData.invoke()
                        }
                    }
                }
            }
        }
    }
}
