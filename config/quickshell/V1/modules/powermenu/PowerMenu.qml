import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../core"

PanelWindow {
    id: root

    signal lockRequested
    // --- 1. Layer Configuration (The Fix) ---
    // This places the window above everything else (Overlay layer)
    WlrLayershell.layer: WlrLayer.Overlay

    // --- 2. Fullscreen Anchors ---
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true

    // --- 3. Window Behavior ---
    // Ignore: Don't reserve space (dock), just float over existing windows
    exclusionMode: ExclusionMode.Ignore

    // Transparent background so we can handle the scrim ourselves
    color: "transparent"
    visible: false

    // --- 4. Content ---
    Rectangle {
        id: scrim
        anchors.fill: parent
        color: Colors.colors.scrim // Or use "#AA000000" if scrim color is missing
        opacity: 0

        // Close on background click
        TapHandler {
            onTapped: root.close()
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 40

        scale: root.visible ? 1 : 0.9
        opacity: root.visible ? 1 : 0

        Behavior on scale {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutBack
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 250
            }
        }

        PowerButton {
            icon: "power_settings_new"
            label: "Shutdown"
            color: Colors.colors.error
            onClicked: root.exec("systemctl poweroff")
        }

        PowerButton {
            icon: "restart_alt"
            label: "Reboot"
            color: Colors.colors.primary
            onClicked: root.exec("systemctl reboot")
        }

        PowerButton {
            icon: "lock"
            label: "Lock"
            color: Colors.colors.tertiary
            onClicked: {
                // [CHANGE THIS]
                // Instead of exec("loginctl..."), we emit the signal
                root.lockRequested();
                root.close();
            }
        }

        PowerButton {
            icon: "logout"
            label: "Logout"
            color: Colors.colors.secondary
            onClicked: root.exec("hyprctl dispatch exit")
        }
    }

    // --- 5. Logic ---
    function open() {
        visible = true;
        scrim.opacity = 0.6;
    }

    function close() {
        scrim.opacity = 0;
        closeTimer.restart();
    }

    // [ADD THIS FUNCTION]
    function toggle() {
        if (visible) {
            close();
        } else {
            open();
        }
    }

    Timer {
        id: closeTimer
        interval: 250
        onTriggered: root.visible = false
    }

    function exec(cmd) {
        var p = Qt.createQmlObject(`import Quickshell.Io; Process {}`, root);
        p.command = ["sh", "-c", cmd];
        p.running = true;
    }
}
