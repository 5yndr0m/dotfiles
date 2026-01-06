import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../core"

ColumnLayout {
    id: quickSettings
    spacing: Theme.values.spacingM
    implicitWidth: parent.width

    RowLayout {
        spacing: Theme.values.spacingM
        QuickButtonLarge {
            icon: "wifi"
            label: NetworkService.isConnected ? NetworkService.connectedName : "Disconnected"
            status: NetworkService.isConnected ? "Connected" : "Disconnected"
            isActive: true
            Layout.fillWidth: true
        }
        QuickButtonLarge {
            icon: "bluetooth"
            label: "Bluetooth"
            status: "Not Connected"
            isActive: false
            Layout.fillWidth: true
        }
    }

    RowLayout {
        spacing: Theme.values.spacingM

        QuickButton {
            icon: "coffee"
            label: "Caffeine"
            isActive: SystemService.caffeineActive
            onClicked: SystemService.toggleCaffeine()
            Layout.fillWidth: true
        }

        QuickButton {
            icon: NotificationService.dndActive ? "notifications_off" : "notifications"
            label: "DND"
            isActive: NotificationService.dndActive
            onClicked: NotificationService.dndActive = !NotificationService.dndActive
            Layout.fillWidth: true
        }

        QuickButton {
            icon: SystemService.recordingActive ? "stop_circle" : "videocam"
            label: SystemService.recordingActive ? "Stop" : "Record"
            isActive: SystemService.recordingActive
            onClicked: SystemService.toggleRecording()
            Layout.fillWidth: true
        }
    }

    component QuickButtonLarge: Rectangle {
        property string icon: ""
        property string label: ""
        property string status: ""
        property bool isActive: false
        signal clicked

        implicitHeight: 60
        radius: Theme.values.roundM
        color: isActive ? Colors.colors.primary : Colors.colors.surface_container_high

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            Text {
                text: parent.parent.icon
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 24
                color: isActive ? Colors.colors.on_primary : Colors.colors.on_surface
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter

                Text {
                    text: parent.parent.parent.status
                    font.family: Theme.values.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    opacity: 0.8
                    color: isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                }

                Text {
                    text: parent.parent.parent.label
                    font.family: Theme.values.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: isActive ? Colors.colors.on_primary : Colors.colors.on_surface
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.clicked()
        }
    }

    component QuickButton: Rectangle {
        property string icon: ""
        property string label: ""
        property bool isActive: false
        signal clicked

        implicitHeight: 60
        radius: Theme.values.roundM
        color: isActive ? Colors.colors.primary : Colors.colors.surface_container_high

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: parent.parent.icon
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 22
                Layout.alignment: Qt.AlignHCenter
                color: isActive ? Colors.colors.on_primary : Colors.colors.on_surface
            }
            Text {
                text: parent.parent.label
                font.family: Theme.values.fontFamily
                font.pixelSize: 10
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
                color: isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: parent.clicked()
        }
    }
}
