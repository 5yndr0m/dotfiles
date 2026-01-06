import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../core"

ColumnLayout {
    id: userInfoRoot
    spacing: 20

    // Properties to allow parent to control size if needed
    Layout.preferredWidth: 250
    Layout.fillHeight: true

    // 1. Large Avatar
    Rectangle {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 120
        Layout.preferredHeight: 120
        radius: width / 2
        color: Colors.colors.surface_container_high
        border.width: 2
        border.color: Colors.colors.primary

        Image {
            id: dashAvatar
            anchors.fill: parent
            anchors.margins: 4
            source: SystemInfo.avatarPath
            fillMode: Image.PreserveAspectCrop
            smooth: true
            visible: status === Image.Ready
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: dashAvatar.width
                    height: dashAvatar.height
                    radius: width / 2
                }
            }
        }
    }

    // 2. User Text Info
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        Text {
            text: "Welcome back,"
            font.family: Theme.values.fontFamily
            font.pixelSize: 14
            color: Colors.colors.on_surface_variant
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: SystemInfo.username
            font.family: Theme.values.fontFamily
            font.pixelSize: 28
            font.bold: true
            color: Colors.colors.primary
            Layout.alignment: Qt.AlignHCenter
        }

        // Spacer
        Item {
            height: 10
            width: 1
        }

        // Uptime Badge
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            color: Colors.colors.surface_container_highest
            height: 32
            width: uptimeRow.implicitWidth + 24
            radius: 16

            RowLayout {
                id: uptimeRow
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "schedule" // Material Icon
                    font.family: Theme.values.fontFamilyMaterial
                    font.pixelSize: 16
                    color: Colors.colors.on_surface
                }
                Text {
                    text: SystemInfo.uptime
                    font.family: Theme.values.fontFamily
                    font.pixelSize: 14
                    font.bold: true
                    color: Colors.colors.on_surface
                }
            }
        }
    }

    // Push content to top
    Item {
        Layout.fillHeight: true
    }
}
