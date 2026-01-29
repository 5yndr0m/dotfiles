import QtQuick
import QtQuick.Layouts
import "../../../core"

RowLayout {
    spacing: tokens.spacingM
    Layout.fillWidth: true

    property var colors
    property var tokens

    Repeater {
        model: [
            {
                icon: NetworkService.isConnected ? "wifi" : "wifi_off",
                label: NetworkService.isConnected ? "Connected" : "Disconnected",
                subValue: NetworkService.isConnected ? NetworkService.connectedName : "Not Connected",
                active: NetworkService.isConnected
            },
            {
                icon: BluetoothService.isPowered ? "bluetooth" : "bluetooth_disabled",
                label: BluetoothService.isPowered ? "Bluetooth" : "Off",
                subValue: !BluetoothService.isPowered ? "Disabled" : (BluetoothService.pairedDevices.length > 0 ? "Connected" : "On"),
                active: BluetoothService.isPowered
            },
            {
                icon: "notifications",
                label: "History",
                subValue: NotificationService.historyModel.count + " New",
                active: NotificationService.historyModel.count > 0
            }
        ]

        delegate: Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 60 // Slightly shorter now without the box

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 2

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: modelData.icon
                        font {
                            family: tokens.fontFamilyMaterial
                            pixelSize: 20
                        }
                        // Use a subtle opacity for inactive icons
                        color: modelData.active ? colors.primary : colors.on_surface_variant
                        opacity: modelData.active ? 1.0 : 0.6
                    }

                    Text {
                        text: modelData.label
                        color: colors.on_surface
                        font {
                            family: tokens.fontFamily
                            pixelSize: 11
                            weight: Font.Medium
                        }
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: modelData.subValue
                    color: colors.on_surface_variant
                    font {
                        family: tokens.fontFamily
                        pixelSize: 10
                    }
                    elide: Text.ElideRight
                    Layout.maximumWidth: parent.parent.width
                    opacity: 0.7
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (index === 0)
                        NetworkService.scan();
                    else if (index === 1)
                        BluetoothService.togglePower();
                }
            }
        }
    }
}
