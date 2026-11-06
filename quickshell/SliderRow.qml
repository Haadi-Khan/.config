import QtQuick
import QtQuick.Layouts

// Icon button + slider (+ optional menu chevron), like GNOME's volume row.
RowLayout {
    id: root

    property string icon
    property real value: 0          // 0..1
    property bool dimmed: false     // e.g. muted
    property bool hasMenu: false
    property bool menuOpen: false
    signal moved(real value)
    signal iconClicked
    signal menuRequested

    spacing: 10

    Rectangle {
        implicitWidth: 36; implicitHeight: 36; radius: 18
        color: iconArea.containsMouse ? Theme.surfaceHover : Theme.surface
        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.dimmed ? Theme.muted : Theme.text
            font { family: Theme.font; pixelSize: 16 }
        }
        MouseArea {
            id: iconArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.iconClicked()
        }
    }

    Item {
        id: track
        Layout.fillWidth: true
        implicitHeight: 36

        readonly property real shown: dragArea.pressed ? dragArea.dragValue : Math.max(0, Math.min(1, root.value))

        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width; height: 6; radius: 3
            color: Theme.surface
        }
        Rectangle {
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(6, track.shown * parent.width); height: 6; radius: 3
            color: root.dimmed ? Theme.muted : Theme.blue
        }
        Rectangle {
            x: track.shown * (parent.width - width)
            anchors.verticalCenter: parent.verticalCenter
            width: 16; height: 16; radius: 8
            color: Theme.textBright
            scale: dragArea.pressed || dragArea.containsMouse ? 1.15 : 1
            Behavior on scale { NumberAnimation { duration: 100 } }
        }

        MouseArea {
            id: dragArea
            property real dragValue: 0
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            function update(x) {
                dragValue = Math.max(0, Math.min(1, x / width));
                root.moved(dragValue);
            }
            onPressed: e => update(e.x)
            onPositionChanged: e => { if (pressed) update(e.x); }
            onWheel: e => root.moved(Math.max(0, Math.min(1, root.value + (e.angleDelta.y > 0 ? 0.05 : -0.05))))
        }
    }

    Rectangle {
        // Kept in the layout (just hidden) so all sliders line up.
        opacity: root.hasMenu ? 1 : 0
        enabled: root.hasMenu
        implicitWidth: 36; implicitHeight: 36; radius: 18
        color: menuArea.containsMouse ? Theme.surfaceHover : "transparent"
        Text {
            anchors.centerIn: parent
            text: root.menuOpen ? "" : ""
            color: Theme.text
            font { family: Theme.font; pixelSize: 11 }
        }
        MouseArea {
            id: menuArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.menuRequested()
        }
    }
}
