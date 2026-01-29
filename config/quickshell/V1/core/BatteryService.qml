pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int percentage: 0
    property string status: "Unknown"
    readonly property bool isCharging: status === "Charging"

    property bool _lowNotified: false
    property bool _fullNotified: false

    Process {
        id: notifyProc
        function send(title, msg, icon) {
            command = ["notify-send", "-i", icon, title, msg];
            running = true;
        }
    }

    Process {
        id: batteryProc
        command: ["sh", "-c", "cat /sys/class/power_supply/BAT0/capacity /sys/class/power_supply/BAT0/status | tr '\\n' ' '"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    let parts = data.trim().split(" ");
                    if (parts.length >= 2) {
                        root.percentage = parseInt(parts[0]);
                        root.status = parts[1];
                        checkNotifications();
                    }
                }
            }
        }
    }

    function checkNotifications() {
        if (percentage < 20 && !isCharging) {
            if (!_lowNotified) {
                notifyProc.send("CORE POWER CRITICAL", "Warning: Fusion core at " + percentage + "%. Direct all remaining power to life support.", "battery_alert");
                _lowNotified = true;
            }
        } else if (percentage > 25) {
            _lowNotified = false;
        }

        if (percentage >= 98 && isCharging) {
            if (!_fullNotified) {
                notifyProc.send("POWER CELLS SATURATED", "Capacitors at 100%. We're giving her all she's got, Captain! Uncouple the power tether.", "battery_charging_full");
                _fullNotified = true;
            }
        } else if (percentage < 90) {
            _fullNotified = false;
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: batteryProc.running = true
    }
}
