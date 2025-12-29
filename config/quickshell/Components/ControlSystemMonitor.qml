import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config

Rectangle {
    id: controlSystemMonitor

    implicitWidth: parent.width - 10
    implicitHeight: 80

    border.width: 2
    border.color: ThemeAuto.outline // Changed from Theme.surface2
    radius: 8
    color: ThemeAuto.bgSurface    // Changed from Theme.crust

    // System monitoring properties
    property int cpuUsage: 0
    property int memUsage: 0
    property int diskUsage: 0
    property string networkRx: "0 B/s"
    property string networkTx: "0 B/s"
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    property var lastRxBytes: 0
    property var lastTxBytes: 0

    // CPU monitoring
    Process {
        id: cpuProc
        command: ["sh", "-c", "head -1 /proc/stat"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var p = data.trim().split(/\s+/);
                var idle = parseInt(p[4]) + parseInt(p[5]);
                var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0);
                if (lastCpuTotal > 0) {
                    cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)));
                }
                lastCpuTotal = total;
                lastCpuIdle = idle;
            }
        }
    }

    // Memory monitoring
    Process {
        id: memProc
        command: ["sh", "-c", "free | grep Mem"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var parts = data.trim().split(/\s+/);
                var total = parseInt(parts[1]) || 1;
                var used = parseInt(parts[2]) || 0;
                memUsage = Math.round(100 * used / total);
            }
        }
    }

    // Disk usage monitoring (root filesystem)
    Process {
        id: diskProc
        command: ["sh", "-c", "df / | tail -1 | awk '{print $5}' | sed 's/%//'"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                diskUsage = parseInt(data.trim()) || 0;
            }
        }
    }

    // Network monitoring
    Process {
        id: networkProc
        command: ["sh", "-c", "IFACE=$(ip route | grep default | awk '{print $5}' | head -1); if [ -n \"$IFACE\" ]; then cat /proc/net/dev | grep \"$IFACE:\" | awk '{print $2, $10}'; else echo '0 0'; fi"]
        stdout: SplitParser {
            onRead: data => {
                if (!data) return;
                var parts = data.trim().split(/\s+/);
                if (parts.length >= 2) {
                    var rxBytes = parseInt(parts[0]) || 0;
                    var txBytes = parseInt(parts[1]) || 0;
                    if (lastRxBytes > 0) {
                        var rxDiff = Math.max(0, rxBytes - lastRxBytes);
                        var txDiff = Math.max(0, txBytes - lastTxBytes);
                        networkRx = formatBytes(rxDiff / 2);
                        networkTx = formatBytes(txDiff / 2);
                    }
                    lastRxBytes = rxBytes;
                    lastTxBytes = txBytes;
                }
            }
        }
    }

    function formatBytes(bytes) {
        if (bytes === 0) return "0 B/s";
        var k = 1024;
        var sizes = ["B/s", "KB/s", "MB/s", "GB/s"];
        var i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + " " + sizes[i];
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            memProc.running = true;
            diskProc.running = true;
            networkProc.running = true;
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        SystemMetric {
            Layout.fillWidth: true
            icon: "memory"
            percentage: cpuUsage
            accentColor: ThemeAuto.accent // Changed from Red/Yellow/Green logic to keep it theme-consistent
        }

        SystemMetric {
            Layout.fillWidth: true
            icon: "storage"
            percentage: memUsage
            accentColor: ThemeAuto.accent
        }

        SystemMetric {
            Layout.fillWidth: true
            icon: "hard_drive"
            percentage: diskUsage
            accentColor: ThemeAuto.accent
        }

        NetworkMetric {
            Layout.fillWidth: true
            icon: "wifi"
            rxValue: networkRx
            txValue: networkTx
        }
    }

    component SystemMetric: Item {
        property string icon: ""
        property int percentage: 0
        property color accentColor: ThemeAuto.accent // Changed from Theme.blue

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Item {
                Layout.alignment: Qt.AlignHCenter
                width: 48
                height: 48

                Rectangle {
                    anchors.centerIn: parent
                    width: 48
                    height: 48
                    radius: width / 2
                    color: "transparent"
                    border.width: 3
                    border.color: ThemeAuto.bgContainer // Changed from Theme.surface1
                }

                Canvas {
                    id: progressCanvas
                    anchors.fill: parent
                    property real progress: percentage / 100
                    onProgressChanged: requestPaint()
                    onPaint: {
                        var ctx = getContext("2d");
                        var centerX = width / 2;
                        var centerY = height / 2;
                        var radius = Math.min(width, height) / 2 - 2;
                        ctx.clearRect(0, 0, width, height);
                        if (progress > 0) {
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, -Math.PI / 2, (-Math.PI / 2) + (2 * Math.PI * progress), false);
                            ctx.strokeStyle = accentColor;
                            ctx.lineWidth = 3;
                            ctx.lineCap = "round";
                            ctx.stroke();
                        }
                    }
                    Behavior on progress {
                        NumberAnimation { duration: 500; easing.type: Easing.OutCubic }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: icon
                    color: accentColor
                    font {
                        family: "Material Symbols Rounded"
                        pixelSize: 20
                    }
                }
            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: percentage + "%"
                color: ThemeAuto.textMain // Changed from Theme.text
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize - 2
                    bold: true
                }
            }
        }
    }

    component NetworkMetric: Item {
        property string icon: ""
        property string rxValue: ""
        property string txValue: ""

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 48
                height: 48
                radius: width / 2
                color: "transparent"
                border.width: 3
                border.color: ThemeAuto.accent // Changed from Theme.blue

                Text {
                    anchors.centerIn: parent
                    text: icon
                    color: ThemeAuto.accent // Changed from Theme.blue
                    font {
                        family: "Material Symbols Rounded"
                        pixelSize: 20
                    }
                }
            }

            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 0

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: rxValue
                    color: ThemeAuto.textMain // Changed from Theme.text
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize - 4
                        bold: true
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "↑ " + txValue
                    color: ThemeAuto.outline // Changed from Theme.subtext1
                    font {
                        family: Theme.fontFamily
                        pixelSize: Theme.fontSize - 4
                    }
                }
            }
        }
    }
}
