pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    property bool isConnected: false
    property string connectedName: "Disconnected"
    property bool isScanning: false
    property var scanResults: []

    function scan() {
        if (!scanProc.running) {
            root.isScanning = true;
            scanProc.running = true;
        }
    }

    function connect(ssid, password) {
        let cmd = ["nmcli", "dev", "wifi", "connect", ssid];
        if (password) {
            cmd.push("password");
            cmd.push(password);
        }
        Quickshell.execDetached(cmd);
        refreshTimer.start();
    }

    function disconnect() {
        Quickshell.execDetached(["nmcli", "device", "disconnect", "wlan0"]);
        refreshTimer.start();
    }

    Timer {
        id: refreshTimer
        interval: 2000
        onTriggered: root.scan()
    }

    property Process scanProc: Process {
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID", "dev", "wifi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                let results = [];
                let foundActive = false;

                for (let line of lines) {
                    let parts = line.split(":");
                    if (parts.length >= 2) {
                        let isActive = (parts[0] === "yes");
                        let ssidName = parts[1];

                        if (isActive) {
                            foundActive = true;
                            root.connectedName = ssidName;
                        }

                        results.push({
                            "active": isActive,
                            "ssid": ssidName
                        });
                    }
                }

                root.isConnected = foundActive;
                if (!foundActive)
                    root.connectedName = "Disconnected";

                root.scanResults = results;
                root.isScanning = false;
            }
        }
    }

    Component.onCompleted: scan()
}
