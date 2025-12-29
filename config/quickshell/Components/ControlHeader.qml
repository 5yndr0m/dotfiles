import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import qs.config
import qs.Components

Rectangle {
    id: controlHeader

    implicitWidth: parent.width - 10
    implicitHeight: 80

    border.width: 2
    border.color: ThemeAuto.outline // Changed from Theme.surface2
    radius: 8
    color: ThemeAuto.bgSurface    // Changed from Theme.crust

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Circular avatar with proper masking
        Rectangle {
            id: avatarContainer
            width: 56
            height: 56
            radius: 28
            color: ThemeAuto.bgContainer // Changed from Theme.surface0
            border.width: 2
            border.color: ThemeAuto.accent   // Changed from Theme.mauve
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: avatarImage
                anchors.fill: parent
                anchors.margins: 2
                source: SystemInfo.avatarPath
                fillMode: Image.PreserveAspectCrop
                smooth: true
                visible: status === Image.Ready

                // --- CIRCULAR CLIPPING FIX ---
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: avatarImage.width
                        height: avatarImage.height
                        radius: avatarImage.width / 2
                    }
                }
                // --------------------------------

                onStatusChanged: {
                    if (status === Image.Ready) {
                        avatarFallback.visible = false;
                    } else if (status === Image.Error || status === Image.Null) {
                        if (source.toString().includes(".pfp.jpg") && SystemInfo.usernameLoaded) {
                            source = SystemInfo.getFallbackAvatarPath();
                        } else {
                            avatarFallback.visible = true;
                        }
                    }
                }
            }

            // Fallback with user initials
            Text {
                id: avatarFallback
                anchors.centerIn: parent
                visible: avatarImage.status !== Image.Ready
                text: SystemInfo.getUserInitials()
                color: ThemeAuto.textMain // Changed from Theme.text
                font {
                    family: Theme.fontFamily
                    pixelSize: 24
                    bold: true
                }
            }
        }

        // User info column
        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 4

            // Username
            Text {
                id: usernameText
                text: SystemInfo.username
                color: ThemeAuto.textMain // Changed from Theme.text
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize + 2
                    bold: true
                }
                Layout.fillWidth: true
            }

            // Uptime
            Text {
                id: uptimeText
                text: SystemInfo.uptime
                color: ThemeAuto.outline // Changed from Theme.subtext1
                font {
                    family: Theme.fontFamily
                    pixelSize: Theme.fontSize - 2
                }
                Layout.fillWidth: true
            }
        }
    }
}
