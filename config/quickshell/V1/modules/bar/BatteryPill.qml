import QtQuick
import QtQuick.Layouts
import "../../core"

Item {
    id: root
    width: 65
    height: 22

    Rectangle {
        anchors.fill: parent
        radius: Theme.values.roundS
        color: Colors.colors.surface_container_highest
        border.color: Colors.colors.outline_variant
        border.width: 1
    }

    Rectangle {
        id: fill
        height: parent.height - 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 2
        radius: Theme.values.roundS - 2

        width: Math.max(0, (parent.width - 4) * (BatteryService.percentage / 100))

        color: {
            if (BatteryService.isCharging)
                return "#4caf50";
            if (BatteryService.percentage < 20)
                return Colors.colors.error;
            return Colors.colors.primary;
        }

        Behavior on width {
            NumberAnimation {
                duration: 800
                easing.type: Easing.OutQuint
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 300
            }
        }
    }

    Row {
        anchors.centerIn: parent
        spacing: 2

        Text {
            text: BatteryService.isCharging ? "bolt" : (BatteryService.percentage < 20 ? "priority_high" : "")
            font.family: Theme.values.fontFamilyMaterial
            font.pixelSize: 12
            color: BatteryService.percentage > 55 ? Colors.colors.on_primary : Colors.colors.on_surface
            visible: text !== ""
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: BatteryService.percentage + "%"
            font.family: Theme.values.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            color: BatteryService.percentage > 55 ? Colors.colors.on_primary : Colors.colors.on_surface
            verticalAlignment: Text.AlignVCenter
        }
    }
}
