pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property string searchText: ""
    property int activeIndex: 0
    property ListModel appsModel: ListModel {}
    property var filteredApps: []

    // Helper to filter the model into the array
    function updateFilter() {
        let query = searchText.toLowerCase().trim();
        let results = [];
        for (let i = 0; i < appsModel.count; i++) {
            let item = appsModel.get(i);
            if (query === "" || item.name.toLowerCase().includes(query) || item.comment.toLowerCase().includes(query)) {
                results.push(item);
            }
        }
        filteredApps = results;
    }

    onSearchTextChanged: {
        activeIndex = 0;
        updateFilter();
    }

    Process {
        id: appLoader
        running: true
        command: ["sh", "-c", "bash " + Quickshell.shellPath("utils/apps.sh")]

        stdout: SplitParser {
            onRead: line => {
                let parts = line.split("|");
                if (parts.length < 4)
                    return;

                appsModel.append({
                    "name": parts[0],
                    "comment": parts[1],
                    "icon": parts[2],
                    "exec": parts[3]
                });

                // Update the visible list as items stream in
                if (searchText === "")
                    updateFilter();
            }
        }

        onStarted: {
            appsModel.clear();
        }

        onExited: code => {
            updateFilter(); // Final pass to ensure everything is caught
        }
    }
}
