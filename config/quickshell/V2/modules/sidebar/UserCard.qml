import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../../core"
import qs.components

Rectangle {
    id: root
    Layout.fillWidth: true
    implicitHeight: 100
    color: "transparent"

    // Custom Button Component using Theme and Colors singletons
    component ActionButton: Control {
        id: control
        property string iconText
        signal clicked

        implicitWidth: 40
        implicitHeight: 40

        contentItem: Text {
            text: control.iconText
            font.family: Theme.settings.fontFamilyMaterial
            font.pixelSize: Theme.settings.iconSizeM
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            // Using primary for hover, on_surface for default
            color: control.hovered ? Colors.colors.primary : Colors.colors.on_surface

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }
        }

        background: Rectangle {
            radius: Theme.settings.roundS
            // Subtle highlight using surface_container_high
            color: control.hovered ? Colors.colors.surface_container_high : "transparent"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: control.clicked()
        }
    }

    RowLayout {
        anchors.fill: parent
        spacing: Theme.settings.spacingL // Using Theme spacing

        // --- USER IMAGE (Quickshell ClippingRectangle) ---
        ClippingRectangle {
            id: imageContainer
            width: 64
            height: 64
            radius: Theme.settings.roundFull // Using Theme's circular radius

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
            spacing: Theme.settings.spacingNone

            Text {
                text: SystemInfo.username
                color: Colors.colors.on_surface
                font.family: Theme.settings.fontFamily
                font.pixelSize: 18
                font.weight: Font.DemiBold
            }

            Text {
                text: "up " + SystemInfo.uptime
                color: Colors.colors.on_surface_variant
                font.family: Theme.settings.fontFamily
                font.pixelSize: 12
            }
        }

        // --- POWER ACTIONS ---
        RowLayout {
            spacing: Theme.settings.spacingXS

            ActionButton {
                iconText: "\ue5d5" // Material: update/restart
                onClicked: Process.run(["reboot"])
            }

            ActionButton {
                iconText: "\ue8ac" // Material: power_settings_new
                onClicked: Process.run(["shutdown", "now"])
            }
        }
    }
}
