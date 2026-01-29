import QtQuick
import QtQuick.Layouts
import "../../../core"

Rectangle {
    id: root
    width: layout.implicitWidth + 24
    height: 36

    color: colors.surface_container_high
    radius: height / 2
    border.color: colors.outline_variant
    border.width: 1

    property var colors
    property var tokens

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 12

        Repeater {
            model: [
                {
                    icon: NetworkService.isConnected ? "signal_wifi_4_bar" : "signal_wifi_off",
                    active: NetworkService.isConnected
                },
                {
                    icon: BluetoothService.isPowered ? "bluetooth" : "bluetooth_disabled",
                    active: BluetoothService.isPowered
                },
                {
                    icon: "notifications",
                    active: NotificationService.historyModel.count > 0
                }
            ]

            delegate: Item {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20

                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    font {
                        family: tokens.fontFamilyMaterial
                        pixelSize: 18
                    }
                    color: modelData.active ? colors.primary : colors.on_surface_variant
                    opacity: modelData.active ? 1.0 : 0.4
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
}
