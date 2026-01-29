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
            text: "Wi-Fi Networks"
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
            checked: NetworkService.wifiEnabled
            onCheckedChanged: NetworkService.toggleWifi(checked)
        }
    }

    // --- Network List ---
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ListView {
            model: NetworkService.scanResults
            spacing: 8

            delegate: Rectangle {
                id: itemDelegate
                width: ListView.view.width
                height: 54
                radius: Theme.settings.roundS
                color: modelData.active ? Colors.colors.primary_container : Colors.colors.surface_container_low

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        text: modelData.secure ? "\ue897" : "\ue63e" // lock vs wifi
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 20
                        color: modelData.active ? Colors.colors.on_primary_container : Colors.colors.on_surface
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true
                        Text {
                            text: modelData.ssid
                            font.family: Theme.settings.fontFamily
                            font.pixelSize: 13
                            font.bold: modelData.active
                            color: modelData.active ? Colors.colors.on_primary_container : Colors.colors.on_surface
                            elide: Text.ElideRight
                        }

                        // Condition replaced with visibility
                        Text {
                            text: "Connected"
                            font.family: Theme.settings.fontFamily
                            font.pixelSize: 10
                            color: Colors.colors.primary
                            visible: modelData.active
                        }
                    }

                    // Condition replaced with visibility
                    Text {
                        text: "\ue876" // checkmark
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 18
                        color: Colors.colors.primary
                        visible: modelData.active
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (!modelData.active) {
                            NetworkService.connect(modelData.ssid, "");
                        }
                    }
                }
            }
        }
    }
}
