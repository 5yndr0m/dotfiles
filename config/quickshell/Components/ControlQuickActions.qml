import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.config

Rectangle {
    id: controlQuickActions

    implicitWidth: parent.width - 10
    implicitHeight: 60

    border.width: 2
    border.color: ThemeAuto.outline // Changed from Theme.surface2
    radius: 8
    color: ThemeAuto.bgSurface    // Changed from Theme.crust

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Power Off Button
        ActionButton {
            id: powerOffButton
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "power_settings_new"
            text: "Power Off"
            accentColor: ThemeAuto.accent // Changed from Theme.red
            onClicked: powerOffProcess.running = true

            Process {
                id: powerOffProcess
                command: ["systemctl", "poweroff"]
            }
        }

        // Boot to BIOS Button
        ActionButton {
            id: biosButton
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: "restart_alt"
            text: "Boot to BIOS"
            accentColor: ThemeAuto.accent // Changed from Theme.yellow
            onClicked: biosProcess.running = true

            Process {
                id: biosProcess
                command: ["systemctl", "reboot", "--firmware-setup"]
            }
        }

        // DND (Do Not Disturb) Button
        ActionButton {
            id: dndButton
            Layout.fillWidth: true
            Layout.fillHeight: true
            property bool dndActive: false
            icon: dndActive ? "notifications_off" : "notifications"
            text: "DND"
            accentColor: ThemeAuto.accent // Changed from Theme.mauve/blue
            onClicked: {
                dndActive = !dndActive;
                if (dndActive) {
                    dndOnProcess.running = true;
                } else {
                    dndOffProcess.running = true;
                }
            }

            Process {
                id: dndOnProcess
                command: ["notify-send", "DND Enabled", "Notifications are now disabled"]
            }

            Process {
                id: dndOffProcess
                command: ["notify-send", "DND Disabled", "Notifications are now enabled"]
            }
        }

        // Toggle Idle Button
        ActionButton {
            id: idleButton
            Layout.fillWidth: true
            Layout.fillHeight: true
            property bool idleInhibited: false
            icon: idleInhibited ? "screen_lock_portrait" : "lock_open"
            text: "Idle"
            accentColor: ThemeAuto.accent // Changed from Theme.green/peach
            onClicked: {
                idleInhibited = !idleInhibited;
                if (idleInhibited) {
                    idleInhibitProcess.running = true;
                } else {
                    idleUnInhibitProcess.running = true;
                }
            }

            Process {
                id: idleInhibitProcess
                command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=User requested", "sleep", "infinity"]
            }

            Process {
                id: idleUnInhibitProcess
                command: ["pkill", "-f", "systemd-inhibit.*idle"]
            }
        }
    }

    // Reusable button component
    component ActionButton: Rectangle {
        property string icon: ""
        property string text: ""
        property color accentColor: ThemeAuto.accent // Changed from Theme.blue
        signal clicked

        Layout.preferredWidth: 40
        Layout.preferredHeight: 40
        radius: width / 2
        color: buttonMouseArea.containsMouse ? ThemeAuto.outline : ThemeAuto.bgContainer // Changed from Theme.surface1/0
        border.width: 2
        border.color: accentColor

        Text {
            anchors.centerIn: parent
            text: icon
            color: accentColor
            font {
                family: "Material Symbols Rounded"
                pixelSize: 20
            }
        }

        MouseArea {
            id: buttonMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: parent.clicked()
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        scale: buttonMouseArea.pressed ? 0.95 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 100
            }
        }
    }
}
