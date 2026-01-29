import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../../core"
import qs.components

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: 70
    color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.settings.paddingM
        anchors.rightMargin: Theme.settings.paddingM
        spacing: Theme.settings.spacingL

        // --- USER IMAGE ---
        ClippingRectangle {
            id: imageContainer
            width: 64
            height: 64
            radius: Theme.settings.roundFull

            Rectangle {
                anchors.fill: parent
                color: Colors.colors.surface_container_high
                Text {
                    anchors.centerIn: parent
                    text: SystemInfo.getUserInitials()
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 24
                    font.bold: true
                    color: Colors.colors.on_surface_variant
                    visible: userImage.status !== Image.Ready
                }
            }

            Image {
                id: userImage
                anchors.fill: parent
                source: SystemInfo.avatarPath
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        // --- USER INFO ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                text: SystemInfo.username
                color: Colors.colors.on_surface
                font.family: Theme.settings.fontFamily
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }

            Text {
                text: BatteryService.getStatusText()
                color: BatteryService.isLow ? Colors.colors.error : Colors.colors.primary
                font.family: Theme.settings.fontFamily
                font.pixelSize: 12
                font.weight: Font.Medium
                opacity: 0.9
            }

            Text {
                text: "Uptime: " + SystemInfo.uptime
                color: Colors.colors.on_surface_variant
                font.family: Theme.settings.fontFamily
                font.pixelSize: 11
            }
        }

        // --- POWER ACTIONS ---
        RowLayout {
            spacing: Theme.settings.spacingXS

            ActionButton {
                iconText: "restart_alt"
                onActionClicked: {
                    // console.log("Button clicked: reboot");
                    Quickshell.execDetached(["systemctl", "reboot"]);
                }
            }

            ActionButton {
                iconText: "power_settings_new"
                onActionClicked: {
                    // console.log("Button clicked: shutdown");
                    Quickshell.execDetached(["systemctl", "poweroff"]);
                }
            }
        }
    }
}
