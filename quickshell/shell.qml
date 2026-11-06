//@ pragma UseQApplication
//@ pragma IconTheme Qogir-Dark
import QtQuick
import Quickshell
import Quickshell.Io

// Notification daemon + GNOME-style dropdown panels for waybar.
//   qs ipc call drawer toggle     notifications + calendar (clock click)
//   qs ipc call control toggle    control center (right island click; see ControlCenter.qml)
//   qs ipc call notifs dnd        toggle Do Not Disturb
//   qs ipc call notifs clear      dismiss all notifications
ShellRoot {
    Popups {}
    DrawerWindow {}
    ControlCenter {}
    Dictation {}

    IpcHandler {
        target: "drawer"
        function toggle(): void { Panels.toggle("drawer"); }
        function open(): void { Panels.open("drawer"); }
        function close(): void { Panels.close(); }
    }

    IpcHandler {
        target: "notifs"
        function dnd(): void { Notifs.dnd = !Notifs.dnd; }
        function clear(): void { Notifs.clearAll(); }
    }

    // Make sure the notification server starts immediately, not on first use.
    Component.onCompleted: Notifs.count
}
