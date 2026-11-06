import QtQuick
import QtQuick.Layouts
import Quickshell

// Month grid with navigation, a dot under days that have events, and the
// selected day's agenda underneath.
ColumnLayout {
    id: root
    spacing: 10

    property date selected: Clock.now
    property int viewYear: Clock.now.getFullYear()
    property int viewMonth: Clock.now.getMonth()
    readonly property int firstDow: Qt.locale().firstDayOfWeek % 7  // 0 = Sunday

    // First cell of the 6x7 grid.
    readonly property date gridStart: {
        const first = new Date(viewYear, viewMonth, 1);
        const offset = (first.getDay() - firstDow + 7) % 7;
        return new Date(viewYear, viewMonth, 1 - offset);
    }
    readonly property date gridEnd: new Date(gridStart.getFullYear(), gridStart.getMonth(), gridStart.getDate() + 42)

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }
    function shiftMonth(n) {
        const d = new Date(viewYear, viewMonth + n, 1);
        viewYear = d.getFullYear();
        viewMonth = d.getMonth();
    }
    function reset() {
        selected = Clock.now;
        viewYear = Clock.now.getFullYear();
        viewMonth = Clock.now.getMonth();
        Events.load(gridStart, gridEnd);
    }

    onGridStartChanged: Events.load(gridStart, gridEnd)

    // ── Big date header (GNOME style) ──
    RowLayout {
        Layout.fillWidth: true
        Layout.bottomMargin: 4

        ColumnLayout {
            spacing: 0
            Text {
                text: Qt.formatDate(Clock.now, "dddd")
                color: Theme.blue
                font { family: Theme.font; pixelSize: 13; bold: true }
            }
            Text {
                text: Qt.formatDate(Clock.now, "MMMM d yyyy")
                color: Theme.textBright
                font { family: Theme.font; pixelSize: 20; bold: true }
            }
        }

        Item { Layout.fillWidth: true }  // spacer: pushes weather flush right

        // Weather, mirroring the two-line date: conditions above, temperature below.
        // Click opens GNOME Weather, same as the bar module.
        Item {
            visible: Weather.available
            Layout.alignment: Qt.AlignRight | Qt.AlignBottom
            implicitWidth: weatherCol.implicitWidth
            implicitHeight: weatherCol.implicitHeight
            opacity: weatherMouse.containsMouse ? 0.8 : 1

            ColumnLayout {
                id: weatherCol
                anchors.fill: parent
                spacing: 0

                Text {
                    Layout.alignment: Qt.AlignRight
                    text: Weather.condition + (Weather.highLow ? "  ·  " + Weather.highLow : "")
                    color: Theme.muted
                    font { family: Theme.font; pixelSize: 13; bold: true }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 8
                    Text {
                        text: Weather.icon
                        color: Theme.yellow
                        font { family: Theme.font; pixelSize: 20 }
                    }
                    Text {
                        text: Weather.temp
                        color: Weather.stale ? Theme.muted : Theme.textBright
                        font { family: Theme.font; pixelSize: 20; bold: true }
                    }
                }
            }

            MouseArea {
                id: weatherMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Quickshell.execDetached(["gnome-weather"])
            }
        }
    }

    // ── Calendar card ──
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: cal.implicitHeight + 20
        radius: 10
        color: Theme.surface

        ColumnLayout {
            id: cal
            anchors { fill: parent; margins: 10 }
            spacing: 6

            RowLayout {
                Layout.fillWidth: true
                NavButton { glyph: ""; onClicked: root.shiftMonth(-1) }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Qt.formatDate(new Date(root.viewYear, root.viewMonth, 1),
                                        root.viewYear === Clock.now.getFullYear() ? "MMMM" : "MMMM yyyy")
                    color: Theme.textBright
                    font { family: Theme.font; pixelSize: 13; bold: true }
                    MouseArea { anchors.fill: parent; onClicked: root.reset() }
                }
                NavButton { glyph: ""; onClicked: root.shiftMonth(1) }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                rowSpacing: 2
                columnSpacing: 2

                Repeater {
                    model: 7
                    Text {
                        required property int index
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: Qt.locale().dayName((index + root.firstDow) % 7, Locale.NarrowFormat)
                        color: Theme.muted
                        font { family: Theme.font; pixelSize: 11; bold: true }
                    }
                }

                Repeater {
                    model: 42
                    Item {
                        id: cell
                        required property int index
                        readonly property date day: new Date(root.gridStart.getFullYear(), root.gridStart.getMonth(), root.gridStart.getDate() + index)
                        readonly property bool inMonth: day.getMonth() === root.viewMonth
                        readonly property bool isToday: root.sameDay(day, Clock.now)
                        readonly property bool isSelected: root.sameDay(day, root.selected)
                        readonly property bool hasEvents: Events.events.length > 0 && Events.on(day).length > 0

                        Layout.fillWidth: true
                        implicitHeight: 34

                        Rectangle {
                            anchors.centerIn: parent
                            width: 32; height: 32; radius: 16
                            color: cell.isToday ? Theme.blue : (cellArea.containsMouse ? Theme.surfaceHover : "transparent")
                            border.width: cell.isSelected && !cell.isToday ? 1 : 0
                            border.color: Theme.blue
                        }

                        Text {
                            anchors.centerIn: parent
                            text: cell.day.getDate()
                            color: cell.isToday ? Theme.bg : (cell.inMonth ? Theme.text : Theme.muted)
                            font { family: Theme.font; pixelSize: 12; bold: cell.isToday }
                        }
                        Rectangle {
                            visible: cell.hasEvents
                            width: 4; height: 4; radius: 2
                            anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 5 }
                            color: cell.isToday ? Theme.bg : Theme.magenta
                        }
                        MouseArea {
                            id: cellArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.selected = cell.day;
                                if (!cell.inMonth) { root.viewYear = cell.day.getFullYear(); root.viewMonth = cell.day.getMonth(); }
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Agenda for the selected day ──
    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 10
        color: Theme.surface

        readonly property var dayEvents: Events.on(root.selected)

        ColumnLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 8

            Text {
                text: root.sameDay(root.selected, Clock.now) ? "Today" : Qt.formatDate(root.selected, "dddd, MMMM d")
                color: Theme.muted
                font { family: Theme.font; pixelSize: 11; bold: true }
            }

            Text {
                Layout.fillWidth: true
                visible: parent.parent.dayEvents.length === 0
                wrapMode: Text.Wrap
                text: !Events.configured ? "Add calendars to ~/.config/quickshell/calendars.conf to see events here."
                    : Events.errors.length ? Events.errors.join("\n")
                    : Events.loading ? "Loading…" : "No events"
                color: Events.errors.length ? Theme.red : Theme.muted
                font { family: Theme.font; pixelSize: 12 }
            }

            ListView {
                id: agenda
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                model: parent.parent.dayEvents
                WheelScroll { flickable: agenda }
                boundsBehavior: Flickable.StopAtBounds

                delegate: Item {
                    id: eventRow
                    required property var modelData
                    width: ListView.view.width
                    implicitHeight: eventLayout.implicitHeight

                    // Click to open the Meet link / event page, if there is one.
                    MouseArea {
                        anchors.fill: parent
                        enabled: !!eventRow.modelData.url
                        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onClicked: Qt.openUrlExternally(eventRow.modelData.url)
                    }

                    RowLayout {
                        id: eventLayout
                        width: parent.width
                        spacing: 10
                        readonly property var modelData: eventRow.modelData

                        Rectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: 3
                            radius: 2
                            color: modelData.color
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            Text {
                                Layout.fillWidth: true
                                text: modelData.title
                                color: Theme.textBright
                                font { family: Theme.font; pixelSize: 12 }
                                elide: Text.ElideRight
                            }
                            Text {
                                Layout.fillWidth: true
                                text: {
                                    const e = modelData;
                                    let when = e.allDay ? "All day"
                                        : Qt.formatTime(new Date(e.start), "h:mm AP") + " – " + Qt.formatTime(new Date(e.end), "h:mm AP");
                                    return e.location ? when + "  ·  " + e.location : when;
                                }
                                color: Theme.muted
                                font { family: Theme.font; pixelSize: 11 }
                                elide: Text.ElideRight
                            }
                        }
                    }
                }
            }
        }
    }

    component NavButton: Rectangle {
        property string glyph
        signal clicked
        implicitWidth: 26; implicitHeight: 26; radius: 13
        color: navArea.containsMouse ? Theme.surfaceHover : "transparent"
        Text {
            anchors.centerIn: parent
            text: parent.glyph
            color: Theme.text
            font { family: Theme.font; pixelSize: 11 }
        }
        MouseArea {
            id: navArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }
    }
}
