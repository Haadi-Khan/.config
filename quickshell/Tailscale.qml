pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Tailscale state via the CLI. Polled only while the control center is open.
// Toggling needs your user to be a Tailscale operator (one-time):
//   sudo tailscale set --operator=$USER
Singleton {
    id: root

    property string state: ""        // Running, Stopped, NeedsLogin, Starting, ...
    property string tailnet: ""
    property string error: ""
    readonly property bool available: state !== ""
    readonly property bool connected: state === "Running"
    readonly property bool busy: toggler.running
    readonly property bool switching: setter.running

    // Exit nodes (Mullvad etc.): [{ name, host, country, countryCode, city, priority, online }]
    property var exitNodes: []
    property var exitNode: null      // the one in use, or null for direct
    property string suggested: ""    // DNS name from `tailscale exit-node suggest`

    // [{ country, countryCode, cities: [city...], count }] sorted by name
    readonly property var countries: {
        const m = {};
        for (const n of exitNodes) {
            if (!m[n.country]) m[n.country] = { country: n.country, countryCode: n.countryCode, cities: [], count: 0 };
            const c = m[n.country];
            c.count++;
            if (n.city && n.city !== "Any" && !c.cities.includes(n.city)) c.cities.push(n.city);
        }
        return Object.values(m)
            .map(c => (c.cities.sort(), c))
            .sort((a, b) => a.country.localeCompare(b.country));
    }

    function flag(code) {
        if (!code || code.length !== 2) return "\udb81\udd82";
        return String.fromCodePoint(...[...code.toUpperCase()].map(ch => 0x1F1E6 + ch.charCodeAt(0) - 65));
    }
    function nodeByName(name) { return exitNodes.find(n => n.name === name) ?? null; }
    function place(n) { return n ? (n.city && n.city !== "Any" ? `${n.city}, ${n.country}` : n.country) : ""; }

    // Best online node for a country (and optionally city): highest priority.
    function bestNode(country, city) {
        const pool = exitNodes.filter(n => n.online && n.country === country && (!city || n.city === city));
        pool.sort((a, b) => b.priority - a.priority);
        return pool[0] ?? null;
    }

    function setExitNode(name) {
        if (setter.running) return;
        error = "";
        setter.command = ["tailscale", "set", "--exit-node=" + (name ?? "")];
        setter.running = true;
    }

    function suggest() { if (!suggester.running) suggester.running = true; }

    function refresh() { if (!status.running) status.running = true; }

    function toggle() {
        if (toggler.running) return;
        error = "";
        toggler.command = ["tailscale", connected ? "down" : "up"];
        toggler.running = true;
    }

    Timer {
        interval: 5000
        repeat: true
        triggeredOnStart: true
        running: Panels.current === "control"
        onTriggered: root.refresh()
    }

    Process {
        id: status
        command: ["tailscale", "status", "--json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.state = d.BackendState ?? "";
                    root.tailnet = d.CurrentTailnet?.Name ?? "";
                    const nodes = [];
                    let active = null;
                    for (const p of Object.values(d.Peer ?? {})) {
                        if (!p.ExitNodeOption) continue;
                        const loc = p.Location ?? {};
                        const n = {
                            name: (p.DNSName ?? "").replace(/\.$/, ""),
                            host: p.HostName,
                            country: loc.Country ?? "My devices",
                            countryCode: loc.CountryCode ?? "",
                            city: loc.City ?? p.HostName,
                            priority: loc.Priority ?? 0,
                            online: p.Online,
                        };
                        nodes.push(n);
                        if (p.ExitNode) active = n;
                    }
                    root.exitNodes = nodes;
                    root.exitNode = active;
                } catch (e) {
                    root.state = "";
                }
            }
        }
    }

    Process {
        id: suggester
        command: ["tailscale", "exit-node", "suggest"]
        stdout: StdioCollector {
            onStreamFinished: {
                const m = text.match(/Suggested exit node: (\S+?)\.?\s/);
                root.suggested = m ? m[1] : "";
            }
        }
    }

    Process {
        id: setter
        stderr: StdioCollector {
            onStreamFinished: if (text.trim()) root.error = text.trim().split("\n")[0]
        }
        onExited: root.refresh()
    }

    Process {
        id: toggler
        stderr: StdioCollector {
            onStreamFinished: {
                if (/access denied|operator/i.test(text)) root.error = "operator";
                else if (text.trim()) root.error = text.trim().split("\n")[0];
            }
        }
        onExited: root.refresh()
    }
}
