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

        delegate: Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70
            radius: 24
            color: colors.surface_container_low
            border.color: modelData.active ? colors.primary : colors.outline_variant
            border.width: modelData.active ? 1.5 : 1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 4
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 8

                    Text {
                        text: modelData.icon
                        font {
                            family: tokens.fontFamilyMaterial
                            pixelSize: 20
                        }
                        color: modelData.active ? colors.primary : colors.on_surface_variant
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
                    Layout.maximumWidth: parent.width - 24
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
