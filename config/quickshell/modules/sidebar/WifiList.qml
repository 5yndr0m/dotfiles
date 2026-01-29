import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../core"

ColumnLayout {
    id: root
    spacing: Theme.settings.spacingL
    Layout.fillWidth: true

    signal back

    // --- Header ---
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 48
        Layout.leftMargin: Theme.settings.paddingM
        Layout.rightMargin: Theme.settings.paddingM
        spacing: 16

        Control {
            id: backBtn
            implicitWidth: 40
            implicitHeight: 40

            background: Rectangle {
                radius: 20
                color: backBtn.hovered ? Colors.colors.surface_container_highest : "transparent"
                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }
                }
            }

            contentItem: Text {
                text: "\ue5c4"
                font.family: Theme.settings.fontFamilyMaterial
                color: Colors.colors.on_surface
                font.pixelSize: 24
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.back()
            }
        }

        Text {
            text: "Wi-Fi Networks"
            font.family: Theme.settings.fontFamily
            font.pixelSize: 22
            font.weight: Font.Normal
            color: Colors.colors.on_surface
            Layout.fillWidth: true
        }

        Switch {
            id: wifiSwitch
            checked: NetworkService.wifiEnabled
            onCheckedChanged: NetworkService.toggleWifi(checked)

            indicator: Rectangle {
                implicitWidth: 52
                implicitHeight: 32
                x: wifiSwitch.leftPadding
                y: parent.height / 2 - height / 2
                radius: 16
                color: wifiSwitch.checked ? Colors.colors.primary : Colors.colors.surface_container_highest
                border.width: 2
                border.color: wifiSwitch.checked ? Colors.colors.primary : Colors.colors.outline

                Rectangle {
                    x: wifiSwitch.checked ? parent.width - width - 4 : 4
                    y: (parent.height - height) / 2
                    width: wifiSwitch.checked ? 24 : 16
                    height: width
                    radius: 12
                    color: wifiSwitch.checked ? Colors.colors.on_primary : Colors.colors.outline

                    Behavior on x {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutQuad
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                        }
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }
            }
        }
    }

    // --- Network List ---
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.leftMargin: Theme.settings.paddingM
        Layout.rightMargin: Theme.settings.paddingM
        clip: true

        ListView {
            model: NetworkService.scanResults
            spacing: 8
            boundsBehavior: Flickable.StopAtBounds

            delegate: ItemDelegate {
                id: itemDelegate
                width: ListView.view.width
                height: 64

                background: Rectangle {
                    radius: Theme.settings.roundM
                    color: modelData.active ? Colors.colors.secondary_container : (itemDelegate.hovered ? Colors.colors.surface_container_high : "transparent")
                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }
                    }
                }

                contentItem: RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 16

                    Text {
                        text: modelData.active ? "signal_wifi_4_bar" : (modelData.secure ? "network_wifi_locked" : "network_wifi")
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 22
                        color: modelData.active ? Colors.colors.primary : Colors.colors.on_surface_variant
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        Text {
                            text: modelData.ssid
                            font.family: Theme.settings.fontFamily
                            font.pixelSize: 16
                            font.weight: modelData.active ? Font.Medium : Font.Normal
                            color: Colors.colors.on_surface
                            elide: Text.ElideRight
                        }

                        Text {
                            text: modelData.active ? "Connected" : (modelData.secure ? "Encrypted" : "Open")
                            font.family: Theme.settings.fontFamily
                            font.pixelSize: 12
                            color: modelData.active ? Colors.colors.primary : Colors.colors.on_surface_variant
                        }
                    }

                    Text {
                        text: "check"
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 20
                        color: Colors.colors.primary
                        visible: modelData.active
                    }
                }

                onClicked: {
                    if (!modelData.active) {
                        NetworkService.connect(modelData.ssid, "");
                    }
                }
            }
        }
    }
}
