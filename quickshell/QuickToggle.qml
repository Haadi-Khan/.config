import QtQuick
import QtQuick.Layouts

// GNOME-style quick settings pill: click the body to toggle, the chevron to
// open its menu.
Rectangle {
    id: root

    property string icon
    property string label
    property string sublabel
    property bool active
    property bool hasMenu: false
    property bool menuOpen: false
    signal toggled
    signal menuRequested

    readonly property color fg: active ? Theme.bg : Theme.text

    implicitHeight: 52
    radius: 26
    color: active ? (bodyArea.containsMouse ? Qt.lighter(Theme.blue, 1.08) : Theme.blue)
                  : (bodyArea.containsMouse ? Theme.surfaceHover : Theme.surface)
    Behavior on color { ColorAnimation { duration: 120 } }

    MouseArea {
        id: bodyArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 16; rightMargin: root.hasMenu ? 4 : 16 }
        spacing: 10

        Text {
            text: root.icon
            color: root.fg
            font { family: Theme.font; pixelSize: 17 }
            Layout.preferredWidth: 20
            horizontalAlignment: Text.AlignHCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                Layout.fillWidth: true
                text: root.label
                color: root.fg
                font { family: Theme.font; pixelSize: 12; bold: true }
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.sublabel
                color: root.fg
                opacity: 0.75
                font { family: Theme.font; pixelSize: 11 }
                elide: Text.ElideRight
            }
        }

        Rectangle {
            visible: root.hasMenu
            Layout.preferredWidth: 36
            Layout.preferredHeight: 44
            radius: 22
            color: chevronArea.containsMouse ? Qt.rgba(0, 0, 0, root.active ? 0.12 : 0.18) : "transparent"

            Text {
                anchors.centerIn: parent
                text: root.menuOpen ? "" : ""
                color: root.fg
                font { family: Theme.font; pixelSize: 11 }
            }
            MouseArea {
                id: chevronArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.menuRequested()
            }
        }
    }
}
