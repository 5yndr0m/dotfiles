pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: root

    // --- Existing Properties ---
    property bool isConnected: false
    property string connectedName: "Disconnected"
    property bool isScanning: false
    property var scanResults: []

    // --- NEW: Radio State ---
    property bool wifiEnabled: true

    function toggleWifi(enable) {
        // Optimistic UI update
        root.wifiEnabled = enable;
        Quickshell.execDetached(["nmcli", "radio", "wifi", enable ? "on" : "off"]);

        if (enable) {
            refreshTimer.restart();
        } else {
            root.scanResults = [];
            root.isConnected = false;
            root.connectedName = "Disconnected";
        }
    }

    function checkRadioStatus() {
        radioProc.running = true;
    }

    // --- Existing Scan Logic ---
    function scan() {
        // Only scan if radio is actually on
        if (root.wifiEnabled && !scanProc.running) {
            root.isScanning = true;
            scanProc.running = true;
        }
    }

    function connect(ssid, password) {
        let cmd = ["nmcli", "dev", "wifi", "connect", ssid];
        if (password && password.length > 0) {
            cmd.push("password");
            cmd.push(password);
        }
        Quickshell.execDetached(cmd);
        refreshTimer.restart();
    }

    function disconnect() {
        Quickshell.execDetached(["nmcli", "device", "disconnect", "wlan0"]);
        refreshTimer.restart();
    }

    // --- Timers & Processes ---

    Timer {
        id: refreshTimer
        interval: 3000
        repeat: true
        running: true
        onTriggered: {
            root.checkRadioStatus(); // Check radio first
            if (root.wifiEnabled)
                root.scan();
        }
    }

    // NEW: Check if Wi-Fi is physically enabled
    property Process radioProc: Process {
        command: ["nmcli", "radio", "wifi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                // Output is usually "enabled\n" or "disabled\n"
                root.wifiEnabled = (text.trim() === "enabled");
            }
        }
    }

    property Process scanProc: Process {
        // ADDED: SECURITY column
        command: ["nmcli", "-t", "-f", "ACTIVE,SSID,SECURITY", "dev", "wifi"]
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.trim().split("\n");
                let results = [];
                let foundActive = false;

                // deduplicate SSIDs (nmcli returns duplicates for multiple APs)
                let seenSSIDs = new Set();

                for (let line of lines) {
                    // Fix split issue if SSID has colons, though rare.
                    // safer to use regex or careful split, but simple split is usually fine for simple SSIDs.
                    let parts = line.split(":");

                    if (parts.length >= 2) {
                        let isActive = (parts[0] === "yes");
                        let ssidName = parts[1];
                        // Security is the 3rd part (index 2), or empty if open
                        let security = parts.length > 2 ? parts[2] : "";

                        if (ssidName === "")
                            continue; // Skip hidden networks

                        if (isActive) {
                            foundActive = true;
                            root.connectedName = ssidName;
                        }

                        if (!seenSSIDs.has(ssidName)) {
                            seenSSIDs.add(ssidName);
                            results.push({
                                "active": isActive,
                                "ssid": ssidName,
                                "secure": security.length > 0,
                                "securityType": security
                            });
                        }
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
