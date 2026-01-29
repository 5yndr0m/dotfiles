import QtQuick
import QtQuick.Layouts
import "../../../core"

Rectangle {
    id: root
    implicitWidth: 85
    implicitHeight: 36
    radius: height / 2
    color: colors.surface_container_low
    border.color: colors.outline_variant
    border.width: 1
    clip: true

    property var colors
    property var tokens

    Rectangle {
        id: batteryFill
        height: parent.height - 8
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 4
        radius: height / 2

        width: Math.max(0, (parent.width - 8) * (BatteryService.percentage / 100))

        color: BatteryService.isCharging ? "#4caf50" : (BatteryService.percentage < 20 ? colors.error : colors.primary)

        // Smoothly slide the bar when percentage changes
        Behavior on width {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuint
            }
        }
    }

    // Content Row
    RowLayout {
        anchors.centerIn: parent
        spacing: 4

        Text {
            text: BatteryService.isCharging ? "bolt" : (BatteryService.percentage < 20 ? "priority_high" : "")
            font.family: tokens.fontFamilyMaterial
            font.pixelSize: 16
            color: (batteryFill.width > parent.width / 2) ? colors.on_primary : colors.on_surface
            visible: text !== ""
        }

        Text {
            text: BatteryService.percentage + "%"
            font {
                family: tokens.fontFamily
                pixelSize: 12
                weight: Font.Bold
            }
            color: (batteryFill.width > parent.width / 1.5) ? colors.on_primary : colors.on_surface
        }
    }
}
