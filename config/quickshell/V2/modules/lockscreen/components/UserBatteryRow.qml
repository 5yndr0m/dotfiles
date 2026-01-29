import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../core"

RowLayout {
    spacing: tokens.spacingM
    Layout.fillWidth: true

    property var colors
    property var tokens

    Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 80
        radius: 28
        color: colors.surface_container_low
        border.color: colors.outline_variant
        border.width: 1

        RowLayout {
            anchors.fill: parent
            anchors.margins: tokens.paddingL
            spacing: tokens.elementSpacingS

            Rectangle {
                id: avatarContainer
                Layout.preferredWidth: 48
                Layout.preferredHeight: 48
                radius: 24
                color: colors.surface_container_high

                Text {
                    anchors.centerIn: parent
                    text: SystemInfo.getUserInitials()
                    color: colors.on_surface_variant
                    font {
                        family: tokens.fontFamily
                        pixelSize: 18
                        bold: true
                    }
                    visible: avatarImage.status !== Image.Ready
                }

                Image {
                    id: avatarImage
                    source: SystemInfo.avatarPath
                    fillMode: Image.PreserveAspectCrop
                    visible: false
                    asynchronous: true
                    onStatusChanged: {
                        if (status === Image.Error)
                            source = SystemInfo.getFallbackAvatarPath();
                    }
                }

                OpacityMask {
                    anchors.fill: parent
                    source: avatarImage
                    visible: avatarImage.status === Image.Ready
                    maskSource: Rectangle {
                        width: 48
                        height: 48
                        radius: 24
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0
                Text {
                    text: SystemInfo.username
                    color: colors.on_surface
                    font {
                        family: tokens.fontFamily
                        pixelSize: 16
                        bold: true
                    }
                    elide: Text.ElideRight
                }
                RowLayout {
                    spacing: 4
                    Text {
                        text: "schedule"
                        font.family: tokens.fontFamilyMaterial
                        font.pixelSize: 12
                        color: colors.on_surface_variant
                    }
                    Text {
                        text: SystemInfo.uptime
                        color: colors.on_surface_variant
                        font {
                            family: tokens.fontFamily
                            pixelSize: 11
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        Layout.preferredWidth: 80
        Layout.preferredHeight: 80
        radius: 28
        color: colors.surface_container_low
        border.color: colors.outline_variant
        border.width: 1

        Rectangle {
            id: batteryFill
            width: parent.width - 8
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 4
            radius: 24
            height: Math.max(0, (parent.height - 8) * (BatteryService.percentage / 100))
            color: BatteryService.isCharging ? "#4caf50" : (BatteryService.percentage < 20 ? colors.error : colors.primary)

            Behavior on height {
                NumberAnimation {
                    duration: 800
                    easing.type: Easing.OutQuint
                }
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            Text {
                text: BatteryService.isCharging ? "bolt" : (BatteryService.percentage < 20 ? "priority_high" : "")
                font.family: tokens.fontFamilyMaterial
                font.pixelSize: 24
                color: BatteryService.percentage > 60 ? colors.on_primary : colors.on_surface
            }
            Text {
                text: BatteryService.percentage + "%"
                font {
                    family: tokens.fontFamily
                    pixelSize: 14
                    weight: Font.Bold
                }
                color: BatteryService.percentage > 60 ? colors.on_primary : colors.on_surface
            }
        }
    }
}
