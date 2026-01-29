pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: service

    property int volume: 0
    property bool isMuted: false

    // Run this initially and whenever volume changes
    function refresh() {
        // -D pulse gets the default sink volume
        proc.command = ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"];
        proc.running = true;
    }

    function setVolume(step) { // step like "5%+" or "5%-"
        exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", step, "-l", "1.5"]);
    }

    function toggleMute() {
        exec(["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]);
    }

    function exec(cmd) {
        let p = Qt.createQmlObject(`import Quickshell.Io; Process { }`, service);
        p.command = cmd;
        p.running = true;
        // Refresh state after command finishes
        p.runningChanged.connect(() => {
            if (!p.running)
                refresh();
        });
    }

    Process {
        id: proc
        stdout: StdioCollector {
            onStreamFinished: {
                if (!text)
                    return;
                // Output format: "Volume: 0.45 [MUTED]"
                let parts = text.trim().split(" ");
                if (parts.length > 1) {
                    service.volume = Math.round(parseFloat(parts[1]) * 100);
                    service.isMuted = text.includes("MUTED");
                }
            }
        }
    }

    // Listen for volume changes automatically
    Process {
        id: listener
        command: ["pactl", "subscribe"]
        running: true
        stdout: StdioCollector {
            onTextChanged: {
                // Whenever sink changes, refresh data
                if (text.includes("sink"))
                    refresh();
            }
        }
    }

    Component.onCompleted: refresh()
}
