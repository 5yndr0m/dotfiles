pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    property int brightness: 0
    property int maxBrightness: 100 // Fallback default

    function increase() {
        let newVal = Math.min(brightness + 5, 100);
        brightness = newVal;
        exec("5%+");
    }

    function decrease() {
        let newVal = Math.max(brightness - 5, 0);
        brightness = newVal;
        exec("5%-");
    }

    function set(value) {
        brightness = value;
        exec(value + "%");
    }

    function exec(arg) {
        // If a process is running, kill it to ensure responsiveness (latest command wins)
        if (proc.running) {
            proc.running = false;
        }

        // Run command: set brightness AND get machine info in one go
        proc.command = ["sh", "-c", "brightnessctl set " + arg + " -q && brightnessctl -m"];
        proc.running = true;
    }

    function refresh() {
        if (proc.running)
            return;
        proc.command = ["brightnessctl", "-m"];
        proc.running = true;
    }

    Process {
        id: proc
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                if (!text)
                    return;

                const lines = text.trim().split("\n");
                // Find line with "backlight" or default to last line
                let targetLine = lines.find(line => line.includes(",backlight,"));
                if (!targetLine && lines.length > 0)
                    targetLine = lines[lines.length - 1];

                if (targetLine) {
                    const parts = targetLine.split(",");

                    // Find the part that ends with "%"
                    const percentPart = parts.find(p => p.includes("%"));

                    if (percentPart) {
                        // parseInt automatically strips the "%" and gives the integer
                        let realPercent = parseInt(percentPart);

                        // Sync the truth
                        if (!isNaN(realPercent)) {
                            service.brightness = realPercent;
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: refresh()
}
