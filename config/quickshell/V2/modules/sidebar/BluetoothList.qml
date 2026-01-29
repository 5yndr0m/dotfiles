import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../core"

ColumnLayout {
    id: root
    spacing: Theme.settings.spacingM

    signal back

    // --- Header ---
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 40

        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: Colors.colors.surface_container_high

            Text {
                anchors.centerIn: parent
                text: "\ue5c4" // arrow_back
                font.family: Theme.settings.fontFamilyMaterial
                color: Colors.colors.on_surface
                font.pixelSize: 18
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.back()
            }
        }

        Text {
            text: "Bluetooth"
            font.family: Theme.settings.fontFamily
            font.pixelSize: 16
            font.bold: true
            color: Colors.colors.on_surface
            Layout.leftMargin: 8
        }

        Item {
            Layout.fillWidth: true
        }

        Switch {
            checked: BluetoothService.isPowered
            onCheckedChanged: {
                if (checked !== BluetoothService.isPowered) {
                    BluetoothService.togglePower();
                }
            }
        }
    }

    // --- Device List ---
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ListView {
            model: BluetoothService.pairedDevices
            spacing: 8

            delegate: Rectangle {
                width: ListView.view.width
                height: 54
                radius: Theme.settings.roundS
                color: modelData.connected ? Colors.colors.primary_container : Colors.colors.surface_container_low

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        // Icon changes based on connection status
                        text: modelData.connected ? "\ue1b1" : "\ue1a7" // bluetooth_connected vs bluetooth
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 20
                        color: modelData.connected ? Colors.colors.on_primary_container : Colors.colors.on_surface
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true
                        Text {
                            text: modelData.name
                            font.family: Theme.settings.fontFamily
                            font.pixelSize: 13
                            font.bold: modelData.connected
                            color: modelData.connected ? Colors.colors.on_primary_container : Colors.colors.on_surface
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.connected ? "Connected" : modelData.mac
                            font.family: Theme.settings.fontFamily
                            font.pixelSize: 10
                            color: modelData.connected ? Colors.colors.on_primary_container : Colors.colors.on_surface_variant
                            opacity: 0.8
                        }
                    }

                    // Checkmark for connected devices
                    Text {
                        text: "\ue876" // checkmark
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 18
                        color: Colors.colors.on_primary_container
                        visible: modelData.connected
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        console.log("Connect to: " + modelData.mac);
                        // Add connection logic to BluetoothService if needed
                    }
                }
            }

            // Empty state if no devices are paired
            Text {
                anchors.centerIn: parent
                text: "No paired devices found"
                visible: parent.count === 0 && BluetoothService.isPowered
                color: Colors.colors.on_surface_variant
                font.family: Theme.settings.fontFamily
                font.pixelSize: 12
            }
        }
    }
}
