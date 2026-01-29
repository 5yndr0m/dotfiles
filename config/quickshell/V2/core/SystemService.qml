pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool caffeineActive: false
    property bool recordingActive: false

    readonly property string scriptPath: Quickshell.env("HOME") + "/.config/quickshell/V2/utils/"
    readonly property string caffeineScript: scriptPath + "caffeine.sh"
    readonly property string recordScript: scriptPath + "record.sh"

    property var _caffeineProc: Process {
        command: [root.caffeineScript]
        onRunningChanged: root.caffeineActive = running
    }

    property var _recorderProc: Process {
        command: [root.recordScript]
        onRunningChanged: root.recordingActive = running
    }

    function toggleCaffeine() {
        if (!caffeineActive) {
            _caffeineProc.running = true;
        } else {
            _caffeineProc.running = false;
        }
    }

    function toggleRecording() {
        if (!recordingActive) {
            _recorderProc.running = true;
        } else {
            _recorderProc.signal(2);
        }
    }
}
