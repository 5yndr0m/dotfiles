import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../core"

Rectangle {
    id: controlSystemMonitor
    implicitWidth: parent.width - 10
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

    // --- PROCESSES (Logic unchanged) ---
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
        anchors.margins: Theme.values.paddingL
        spacing: Theme.values.elementSpacingS

        RowLayout {
            Layout.fillHeight: true
            spacing: Theme.values.paddingL

            MonitorGraph {
                title: "CPU"
                dataArray: cpuHistory
                accentColor: Colors.colors.primary || "transparent"
            }

            MonitorGraph {
                title: "RAM"
                dataArray: memHistory
                accentColor: Colors.colors.secondary || "transparent"
            }
        }

        // Bottom Tier: Secondary Metrics
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 24

            // --- STORAGE ---
            RowLayout {
                spacing: Theme.values.spacingS
                Text {
                    text: "storage"
                    font.family: Theme.values.fontFamilyMaterial
                    font.pixelSize: Theme.values.iconSizeS
                    color: Colors.colors.tertiary || "transparent"
                }

                Text {
                    text: "Disk"
                    font {
                        family: Theme.values.fontFamily
                        pixelSize: Theme.values.fontSize - 2
                    }
                    color: Colors.colors.on_surface_variant || "transparent"
                }

                Text {
                    text: diskUsage + "%"
                    font {
                        family: "Monospace"
                        pixelSize: 11
                        bold: true
                    }
                    color: Colors.colors.on_surface || "transparent"
                    Layout.preferredWidth: 35
                }
            }

            Item {
                Layout.fillWidth: true
            } // Spacer

            // --- NETWORK ---
            RowLayout {
                spacing: Theme.values.spacingS
                Text {
                    text: "wifi"
                    font.family: Theme.values.fontFamilyMaterial
                    font.pixelSize: Theme.values.iconSizeS
                    color: Colors.colors.primary || "transparent"
                }

                Text {
                    text: networkRx
                    font {
                        family: "Monospace"
                        pixelSize: 11
                        bold: true
                    }
                    color: Colors.colors.on_surface || "transparent"
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 75
                }
            }
        }
    }

    // --- MonitorGraph Component ---
    component MonitorGraph: ColumnLayout {
        property string title: ""
        property var dataArray: []
        property color accentColor: "white"

        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 2

        RowLayout {
            Layout.fillWidth: true
            Text {
                text: title
                color: accentColor
                font {
                    family: Theme.values.fontFamily
                    pixelSize: 10
                    bold: true
                }
                Layout.fillWidth: true
            }
            Text {
                property int val: dataArray.length > 0 ? dataArray[dataArray.length - 1] : 0
                text: val + "%"
                color: Colors.colors.on_surface || "transparent"
                font {
                    family: "Monospace"
                    pixelSize: 10
                    bold: true
                }
                Layout.preferredWidth: 30
                horizontalAlignment: Text.AlignRight
            }
        }

        Canvas {
            id: graphCanvas
            Layout.fillWidth: true
            Layout.fillHeight: true

            onPaint: {
                var ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                if (dataArray.length < 2)
                    return;

                let step = width / 29;

                // --- 1. Draw the Filled Area ---
                ctx.beginPath();
                ctx.moveTo(0, height);
                for (let i = 0; i < dataArray.length; i++) {
                    ctx.lineTo(i * step, height - (dataArray[i] / 100 * height));
                }
                ctx.lineTo((dataArray.length - 1) * step, height);
                ctx.closePath();

                let gradient = ctx.createLinearGradient(0, 0, 0, height);
                gradient.addColorStop(0, Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.3));
                gradient.addColorStop(1, Qt.rgba(accentColor.r, accentColor.g, accentColor.b, 0.02));

                ctx.fillStyle = gradient;
                ctx.fill();

                // --- 2. Draw the Line ---
                ctx.beginPath();
                ctx.lineWidth = 1.5;
                ctx.strokeStyle = accentColor;
                ctx.lineCap = "round";
                ctx.lineJoin = "round";

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

            Connections {
                target: controlSystemMonitor
                function onCpuHistoryChanged() {
                    graphCanvas.requestPaint();
                }
                function onMemHistoryChanged() {
                    graphCanvas.requestPaint();
                }
            }
        }
    }
}
