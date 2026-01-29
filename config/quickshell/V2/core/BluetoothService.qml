pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool isPowered: false
    property var pairedDevices: []

    Process {
        id: oneShotProc
        function runCmd(cmd) {
            command = cmd;
            running = true;
        }
        onExited: code => {
            refreshStatus();
        }
    }

    function refreshStatus() {
        statusProc.running = true;
    }

    function togglePower() {
        let action = isPowered ? "power off" : "power on";
        oneShotProc.runCmd(["bluetoothctl", action]);
    }

    Process {
        id: statusProc
        command: ["bluetoothctl", "show"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                root.isPowered = data.includes("Powered: yes");
                pairedProc.running = true;
            }
        }
    }

    Process {
        id: pairedProc
        command: ["bluetoothctl", "paired-devices"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                let results = [];
                let lines = data.trim().split("\n");
                for (let line of lines) {
                    let parts = line.split(" ");
                    if (parts.length >= 3) {
                        results.push({
                            mac: parts[1],
                            name: parts.slice(2).join(" "),
                            connected: false
                        });
                    }
                }
                root.pairedDevices = results;
                infoProc.running = true;
            }
        }
    }

    Process {
        id: infoProc
        command: ["bluetoothctl", "devices", "Connected"]
        stdout: SplitParser {
            onRead: data => {
                if (!data)
                    return;
                let devices = root.pairedDevices;
                for (let i = 0; i < devices.length; i++) {
                    devices[i].connected = data.includes(devices[i].mac);
                }
                root.pairedDevices = devices;
            }
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: refreshStatus()
    }
}
