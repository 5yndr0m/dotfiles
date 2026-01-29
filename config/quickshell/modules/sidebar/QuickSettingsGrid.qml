import QtQuick
import QtQuick.Layouts
import qs.components
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
            icon: "network_wifi"
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
            icon: "coffee"
            label: "Caffeine"
            isActive: SystemService.caffeineActive
            onClicked: SystemService.toggleCaffeine()
            Layout.fillWidth: true
        }

        QuickButton {
            icon: NotificationService.dndActive ? "do_not_disturb_on" : "notifications_off"
            label: "DND"
            isActive: NotificationService.dndActive
            onClicked: NotificationService.dndActive = !NotificationService.dndActive
            Layout.fillWidth: true
        }

        QuickButton {
            icon: SystemService.recordingActive ? "stop_circle" : "fiber_manual_record"
            label: SystemService.recordingActive ? "Stop" : "Record"
            isActive: SystemService.recordingActive
            onClicked: SystemService.toggleRecording()
            Layout.fillWidth: true
        }
    }
}
