pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

Item {
    id: service
    property bool capsLock: false

    // Hyprland exposes keyboard state directly if using the module
    // But getting the LED state specifically can be tricky without an IPC check.
    // The easiest reliable way is reading the LED file or using 'hyprctl devices'

    // Simple poller or IPC listener
    Timer {
        interval: 500
        repeat: true
        running: true
        onTriggered: proc.running = true
    }

    Process {
        id: proc
        // Getting raw brightness from the input LED class often works universally on Linux
        // Check /sys/class/leds/ to find your keyboard identifier (e.g., input3::capslock)
        // Or generic "capslock" if available.
        // A safer generic way is using python or C, but here is a 'brightnessctl' trick:
        command: ["sh", "-c", "cat /sys/class/leds/*capslock*/brightness 2>/dev/null"]

        stdout: StdioCollector {
            onTextChanged: {
                if (text)
                    service.capsLock = (text.trim() == "1");
            }
        }
    }
}
