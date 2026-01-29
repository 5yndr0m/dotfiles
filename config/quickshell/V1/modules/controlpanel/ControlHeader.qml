import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import "../../core"
import qs.components

Rectangle {
    id: controlHeader

    implicitWidth: parent.width
    implicitHeight: Theme.values.barHeightM * 1.1

    color: "transparent"
    property var controlPanelWindow: null

    Process {
        id: shutdownProcess
        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProcess
        command: ["systemctl", "reboot"]
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 0
        spacing: Theme.values.spacingS

        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: Theme.values.roundFull
            color: Colors.colors.surface_container_high || "transparent"
            border.width: 1
            border.color: Colors.colors.primary || "transparent"
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: avatarImage
                anchors.fill: parent
                anchors.margins: 2
                source: SystemInfo.avatarPath
                fillMode: Image.PreserveAspectCrop
                smooth: true
                visible: status === Image.Ready
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: avatarImage.width
                        height: avatarImage.height
                        radius: avatarImage.width / 2
                    }
                }
            }

            Text {
                id: avatarFallback
                anchors.centerIn: parent
                visible: avatarImage.status !== Image.Ready
                text: SystemInfo.getUserInitials()
                color: Colors.colors.on_surface || "#cdd6f4"
                font {
                    family: Theme.values.fontFamily
                    pixelSize: 24
                    bold: true
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: Theme.values.spacingNone

            Text {
                id: usernameText
                text: SystemInfo.username
                color: Colors.colors.on_surface || "#cdd6f4"
                font {
                    family: Theme.values.fontFamily
                    pixelSize: Theme.values.fontSize
                    bold: true
                }
            }

            Text {
                id: uptimeText
                text: SystemInfo.uptime
                color: Colors.colors.on_surface_variant || "#7f849c"
                font {
                    family: Theme.values.fontFamily
                    pixelSize: Theme.values.fontSize - 2
                }
            }
        }

        Item {
            Layout.fillWidth: true
        }

        RowLayout {
            spacing: Theme.values.spacingS
            Layout.alignment: Qt.AlignVCenter

            property var settingsLoader: null

            HeaderButton {
                icon: "restart_alt"
                accentColor: Colors.colors.primary
                onClicked: {
                    if (controlPanelWindow) {
                        controlPanelWindow.visible = false;
                    }
                    rebootProcess.running = true;
                }
            }

            HeaderButton {
                icon: "power_settings_new"
                accentColor: Colors.colors.error || "#f38ba8"
                onClicked: {
                    if (controlPanelWindow) {
                        controlPanelWindow.visible = false;
                    }
                    shutdownProcess.running = true;
                }
            }
        }
    }
}
