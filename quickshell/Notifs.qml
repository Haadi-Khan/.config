pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// Notification daemon (replaces mako). Every notification is kept in the
// drawer history until dismissed; `popups` is the subset currently on screen.
Singleton {
    id: root

    property bool dnd: false
    property list<QtObject> popups: []
    // Receive time (ms) per notification id. Plain object keyed by id: a
    // WeakMap keyed by Notification objects crashed Qt's JS engine. When an
    // app replaces a notification (same id) the time updates, which is what
    // we want anyway.
    property var times: ({})

    readonly property var history: server.trackedNotifications.values.slice().reverse()
    readonly property int count: server.trackedNotifications.values.length

    function timeOf(n) { return new Date(times[n.id] ?? Date.now()); }

    function removePopup(n) {
        popups = popups.filter(p => p !== n);
    }

    function clearAll() {
        // Copy first: dismissing mutates the tracked list.
        for (const n of server.trackedNotifications.values.slice())
            n.dismiss();
    }

    function activate(n) {
        const def = n.actions.find(a => a.identifier === "default");
        if (def) def.invoke();
        else n.dismiss();
    }

    NotificationServer {
        id: server
        keepOnReload: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            n.tracked = true;
            root.times[n.id] = Date.now();
            n.closed.connect(() => root.removePopup(n));
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                root.popups = [n, ...root.popups.filter(p => p !== n)].slice(0, 5);
        }
    }
}
