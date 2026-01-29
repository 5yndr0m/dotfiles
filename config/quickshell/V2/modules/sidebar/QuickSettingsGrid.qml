import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../../core"

ColumnLayout {
    id: quickSettings
    spacing: Theme.settings.spacingM
    Layout.fillWidth: true

    signal wifiClicked
    signal bluetoothClicked

    // --- ROW 1: Large Buttons ---
    RowLayout {
        spacing: Theme.settings.spacingM
        Layout.fillWidth: true

        QuickButtonLarge {
            id: wifiBtn
            icon: "\ue63e"
            label: NetworkService.isConnected ? NetworkService.connectedName : "Disconnected"
            status: NetworkService.wifiEnabled ? (NetworkService.isConnected ? "Connected" : "Available") : "Off"
            isActive: NetworkService.isConnected
            Layout.fillWidth: true
            onClicked: quickSettings.wifiClicked()
        }

        QuickButtonLarge {
            id: btBtn
            icon: "bluetooth"
            label: "Bluetooth"
            status: BluetoothService.isPowered ? (BluetoothService.pairedDevices.length + " Paired") : "Off"
            isActive: BluetoothService.isPowered
            Layout.fillWidth: true
            onClicked: quickSettings.bluetoothClicked()
        }
    }

    // --- ROW 2: Standard Buttons ---
    RowLayout {
        spacing: Theme.settings.spacingM
        Layout.fillWidth: true

        QuickButton {
            icon: "\uefef"
            label: "Caffeine"
            isActive: SystemService.caffeineActive
            onClicked: SystemService.toggleCaffeine()
            Layout.fillWidth: true
        }

        QuickButton {
            icon: NotificationService.dndActive ? "\ue7f6" : "\ue7f4"
            label: "DND"
            isActive: NotificationService.dndActive
            onClicked: NotificationService.dndActive = !NotificationService.dndActive
            Layout.fillWidth: true
        }

        QuickButton {
            icon: SystemService.recordingActive ? "\ue061" : "\ue04b"
            label: SystemService.recordingActive ? "Stop" : "Record"
            isActive: SystemService.recordingActive
            onClicked: SystemService.toggleRecording()
            Layout.fillWidth: true
        }
    }

    // --- COMPONENT: QuickButtonLarge ---
    component QuickButtonLarge: Rectangle {
        id: largeBtn
        property string icon: ""
        property string label: ""
        property string status: ""
        property bool isActive: false
        signal clicked

        implicitHeight: 64
        radius: Theme.settings.roundM
        color: largeBtn.isActive ? Colors.colors.primary : Colors.colors.surface_container_high

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: largeBtn.icon
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: 24
                // Explicitly use largeBtn.isActive to ensure correct color
                color: largeBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                Text {
                    text: largeBtn.status
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    opacity: 0.8
                    color: largeBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant
                }

                Text {
                    text: largeBtn.label
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: largeBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: largeBtn.clicked()
        }
    }

    // --- COMPONENT: QuickButton ---
    component QuickButton: Rectangle {
        id: smallBtn
        property string icon: ""
        property string label: ""
        property bool isActive: false
        signal clicked

        implicitHeight: 64
        radius: Theme.settings.roundM
        color: smallBtn.isActive ? Colors.colors.primary : Colors.colors.surface_container_high

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: smallBtn.icon
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: 22
                color: smallBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
            }
            Text {
                text: smallBtn.label
                font.family: Theme.settings.fontFamily
                font.pixelSize: 10
                font.bold: true
                color: smallBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: smallBtn.clicked()
        }
    }
}
