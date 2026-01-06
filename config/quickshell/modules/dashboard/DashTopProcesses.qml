import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../core"

Rectangle {
    id: root
    color: Colors.colors.surface_container_low
    radius: Theme.values.roundL
    clip: true

    // List Model to store the process data
    ListModel {
        id: processModel
    }

    // Process to fetch data
    Process {
        id: psProc
        // Fetch Top 5 processes by CPU.
        // Format: comm (command name), pcpu (cpu %)
        // tail -n +2 skips the header
        command: ["sh", "-c", "ps -eo comm,pcpu --sort=-pcpu | head -n 6 | tail -n +2"]

        stdout: SplitParser {
            onRead: data => {
                processModel.clear();
                let lines = data.trim().split("\n");

                lines.forEach(line => {
                    // Split by whitespace
                    let parts = line.trim().split(/\s+/);
                    if (parts.length >= 2) {
                        let usage = parts.pop(); // Last part is always %CPU
                        let name = parts.join(" "); // Rest is the name

                        // Clean up brackets often found in kernel threads
                        name = name.replace("[", "").replace("]", "");
                        // Capitalize first letter
                        name = name.charAt(0).toUpperCase() + name.slice(1);

                        processModel.append({
                            "name": name,
                            "usage": usage
                        });
                    }
                });
            }
        }
    }

    // Refresh every 2 seconds
    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: psProc.running = true
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        // Header
        RowLayout {
            spacing: 8
            Text {
                text: "leaderboard" // Icon
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 18
                color: Colors.colors.tertiary
            }
            Text {
                text: "Top Processes"
                font.family: Theme.values.fontFamily
                font.pixelSize: 14
                font.bold: true
                color: Colors.colors.on_surface
            }
        }

        // The List
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: processModel
            clip: true
            spacing: 8

            delegate: Rectangle {
                width: ListView.view.width
                height: 36
                color: Colors.colors.surface_container_highest
                radius: 8

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8

                    // Icon placeholder (using first letter)
                    Rectangle {
                        width: 20
                        height: 20
                        radius: 6
                        color: Colors.colors.primary
                        opacity: 0.2
                        Text {
                            anchors.centerIn: parent
                            text: model.name.charAt(0)
                            font.bold: true
                            font.pixelSize: 12
                            color: Colors.colors.primary
                        }
                    }

                    Text {
                        text: model.name
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                        color: Colors.colors.on_surface
                        font.family: Theme.values.fontFamily
                        font.pixelSize: 13
                    }

                    Text {
                        text: model.usage + "%"
                        color: parseFloat(model.usage) > 20 ? Colors.colors.error : Colors.colors.secondary
                        font.family: "Monospace"
                        font.bold: true
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
