import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.components
import "../../core"

Rectangle {
    id: root
    implicitWidth: parent.width
    implicitHeight: 180
    color: "transparent"

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    Process {
        id: brightnessProc
        command: ["brightnessctl", "g"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: brightnessController.current = Number(this.text.trim())
        }
    }

    Process {
        id: brightnessMax
        command: ["brightnessctl", "m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: brightnessController.max = Number(this.text.trim())
        }
    }

    Process {
        id: setBrightnessProc
    }

    QtObject {
        id: brightnessController
        property int current: 0
        property int max: 1
        property real ratio: max > 0 ? current / max : 0

        function set(val) {
            let percent = Math.max(2, Math.round(val * 100));
            setBrightnessProc.running = false;
            setBrightnessProc.command = ["brightnessctl", "s", percent + "%"];
            setBrightnessProc.running = true;
            current = Math.round((percent / 100) * max);
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            brightnessProc.running = false;
            brightnessProc.running = true;
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: Theme.values.elementSpacingS

        M3Slider {
            icon: (Pipewire.defaultAudioSink?.audio?.muted) ? "volume_off" : "volume_up"
            name: "Volume"
            value: Pipewire.defaultAudioSink?.audio?.volume || 0
            accentColor: Colors.colors.primary || "transparent"
            Layout.fillWidth: true
            onMoved: val => {
                if (Pipewire.defaultAudioSink?.audio)
                    Pipewire.defaultAudioSink.audio.volume = val;
            }
        }

        M3Slider {
            icon: (Pipewire.defaultAudioSource?.audio?.muted) ? "mic_off" : "mic"
            name: "Microphone"
            value: Pipewire.defaultAudioSource?.audio?.volume || 0
            accentColor: Colors.colors.secondary || "transparent"
            Layout.fillWidth: true
            onMoved: val => {
                if (Pipewire.defaultAudioSource?.audio)
                    Pipewire.defaultAudioSource.audio.volume = val;
            }
        }

        M3Slider {
            icon: "light_mode"
            name: "Brightness"
            value: brightnessController.ratio
            accentColor: Colors.colors.tertiary || "transparent"
            Layout.fillWidth: true
            onMoved: val => brightnessController.set(val)
        }
    }
}
