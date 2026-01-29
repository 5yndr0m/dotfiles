import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../core"

Rectangle {
    id: controlSystemMonitor
    Layout.fillWidth: true
    implicitHeight: 160
    color: "transparent"

    // --- DATA STATE ---
    property var cpuHistory: [0]
    property var memHistory: [0]
    property int diskUsage: 0
    property string networkRx: "0 B/s"
    property var lastCpu: {
        "idle": 0,
        "total": 0
    }
    property var lastRx: 0

    function pushData(arr, val) {
        let newArr = [...arr];
        newArr.push(val);
        if (newArr.length > 30)
            newArr.shift();
        return newArr;
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            diskProc.running = true;
            netProc.running = true;
        }
    }

    // --- PROCESSES ---
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                let p = data.trim().split(/\s+/);
                let idle = parseInt(p[4]) + parseInt(p[5]);
                let total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (lastCpu.total > 0) {
                    let usage = Math.round(100 * (1 - (idle - lastCpu.idle) / (total - lastCpu.total)));
                    cpuHistory = pushData(cpuHistory, usage);
                }
                lastCpu = {
                    "idle": idle,
                    "total": total
                };
            }
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem | awk '{print $3/$2 * 100}'"]
        stdout: SplitParser {
            onRead: data => memHistory = pushData(memHistory, parseInt(data))
        }
    }

    Process {
        id: diskProc
        command: ["sh", "-c", "df / | tail -1 | awk '{print $5}' | sed 's/%//'"]
        stdout: SplitParser {
            onRead: data => diskUsage = parseInt(data.trim()) || 0
        }
    }

    Process {
        id: netProc
        command: ["sh", "-c", "cat /proc/net/dev | grep $(ip route | grep default | awk '{print $5}') | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                let rx = parseInt(data.trim());
                if (lastRx > 0)
                    networkRx = formatBytes(rx - lastRx);
                lastRx = rx;
            }
        }
    }

    function formatBytes(b) {
        if (b < 1024)
            return b + " B/s";
        if (b < 1048576)
            return (b / 1024).toFixed(1) + " K/s";
        return (b / 1048576).toFixed(1) + " M/s";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.settings.spacingM

        RowLayout {
            Layout.fillHeight: true
            spacing: Theme.settings.spacingM

            MonitorGraph {
                title: "CPU"
                dataArray: cpuHistory
                accentColor: Colors.colors.primary
            }

            MonitorGraph {
                title: "RAM"
                dataArray: memHistory
                accentColor: Colors.colors.secondary
            }
        }

        // Bottom Tier
        // --- BOTTOM TIER ---
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24

            // --- STORAGE ---
            RowLayout {
                spacing: 8
                Text {
                    text: "\ue2c7"
                    font.family: Theme.settings.fontFamilyMaterial
                    font.pixelSize: 16
                    color: Colors.colors.tertiary
                }
                Text {
                    text: "Disk"
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 11
                    color: Colors.colors.on_surface_variant
                }
                Text {
                    text: diskUsage + "%"
                    // FIXED WIDTH: Prevents Disk % from pushing the spacer
                    Layout.preferredWidth: 35
                    font.family: "Monospace"
                    font.pixelSize: 11
                    color: Colors.colors.on_surface
                }
            }

            Item {
                Layout.fillWidth: true
            } // This spacer will now stay static

            // --- NETWORK ---
            RowLayout {
                spacing: 8
                Text {
                    text: "\ue63e"
                    font.family: Theme.settings.fontFamilyMaterial
                    font.pixelSize: 16
                    color: Colors.colors.primary
                }
                Text {
                    text: networkRx
                    // FIXED WIDTH: Prevents speed changes from "wiggling" the layout
                    // 75px is usually enough for "999.9 M/s"
                    Layout.preferredWidth: 75
                    horizontalAlignment: Text.AlignRight
                    font.family: "Monospace"
                    font.pixelSize: 11
                    color: Colors.colors.on_surface
                }
            }
        }
    }

    component MonitorGraph: ColumnLayout {
        property string title: ""
        property var dataArray: []
        property color accentColor: "white"

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: title
                color: accentColor
                font {
                    family: Theme.settings.fontFamily
                    pixelSize: 10
                    bold: true
                }
                Layout.fillWidth: true
            }
            Text {
                // Calculate value once to avoid multiple evaluations
                property int val: dataArray.length > 0 ? dataArray[dataArray.length - 1] : 0
                text: val + "%"
                color: Colors.colors.on_surface

                // 1. Set a fixed width large enough for "100%"
                Layout.preferredWidth: 35

                // 2. Align the text to the right within that fixed width
                horizontalAlignment: Text.AlignRight

                font {
                    family: "Monospace"
                    pixelSize: 10
                    bold: true
                }
            }
        }

        Canvas {
            id: graphCanvas
            Layout.fillWidth: true
            Layout.fillHeight: true
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.clearRect(0, 0, width, height);
                if (dataArray.length < 2)
                    return;
                let step = width / (dataArray.length - 1);

                // Fill
                ctx.beginPath();
                ctx.moveTo(0, height);
                for (let i = 0; i < dataArray.length; i++) {
                    ctx.lineTo(i * step, height - (dataArray[i] / 100 * height));
                }
                ctx.lineTo(width, height);
                let grad = ctx.createLinearGradient(0, 0, 0, height);
                grad.addColorStop(0, Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3));
                grad.addColorStop(1, Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.0));
                ctx.fillStyle = grad;
                ctx.fill();

                // Line
                ctx.beginPath();
                ctx.strokeStyle = accentColor;
                ctx.lineWidth = 1.5;
                for (let i = 0; i < dataArray.length; i++) {
                    let x = i * step;
                    let y = height - (dataArray[i] / 100 * height);
                    if (i === 0)
                        ctx.moveTo(x, y);
                    else
                        ctx.lineTo(x, y);
                }
                ctx.stroke();
            }

            // Re-paint when data changes
            onVisibleChanged: if (visible)
                requestPaint()
        }

        // Connect to changes to trigger repaint
        Connections {
            target: controlSystemMonitor
            function onCpuHistoryChanged() {
                if (title === "CPU")
                    graphCanvas.requestPaint();
            }
            function onMemHistoryChanged() {
                if (title === "RAM")
                    graphCanvas.requestPaint();
            }
        }
    }
}
