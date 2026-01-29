pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../utils/fuzzysort.js" as Fuzzysort

Item {
    id: root

    property bool windowVisible: false
    property var resultsModel: ListModel {}

    property var appCache: []

    readonly property string terminal: "foot"
    readonly property string fileManager: "nautilus"
    readonly property string browser: "zen-browser"

    readonly property string listAppsScript: Qt.resolvedUrl("../utils/apps.sh").toString().replace("file://", "")

    function toggle() {
        windowVisible = !windowVisible;
    }

    Process {
        id: loadAppsProcess
        command: ["bash", "-c", root.listAppsScript]
        running: true

        stdout: SplitParser {
            onRead: data => {
                if (data.trim() === "")
                    return;

                const parts = data.split("|");
                if (parts.length >= 2) {
                    const name = parts[0];
                    const exec = parts[1];
                    const icon = parts[2] || "application-x-executable";

                    root.appCache.push({
                        name: name,
                        exec: exec,
                        icon: icon,
                        searchStr: name + " " + exec
                    });
                }
            }
        }

        onExited: console.log(`Loaded ${root.appCache.length} apps into memory.`)
    }

    function search(query) {
        const q = query.trim();
        resultsModel.clear();

        if (q === "" || q.startsWith(">") || q.startsWith("?") || q.startsWith("/"))
            return;

        const results = Fuzzysort.go(q, root.appCache, {
            key: 'searchStr',
            limit: 8,
            threshold: -10000
        });

        results.forEach(res => {
            resultsModel.append({
                "name": res.obj.name,
                "exec": res.obj.exec,
                "icon": res.obj.icon
            });
        });
    }

    function launch(index) {
        if (index >= 0 && index < resultsModel.count) {
            const cmd = resultsModel.get(index).exec;
            Quickshell.execDetached(["sh", "-c", cmd]);
        }
    }

    function execute(query) {
        const q = query.trim();
        if (q === "")
            return;

        if (q.startsWith(">")) {
            Quickshell.execDetached([root.terminal, "sh", "-c", q.substring(1).trim()]);
        } else if (q.startsWith("?")) {
            Quickshell.execDetached([root.browser, "--search", q.substring(1).trim()]);
        } else if (q.startsWith("/")) {
            Quickshell.execDetached([root.fileManager, q]);
        } else {
            Quickshell.execDetached(["sh", "-c", q]);
        }
    }
}
