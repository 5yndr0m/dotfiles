import QtQuick
import QtQuick.Layouts
import "../../core"

Item {
    id: root
    width: 65
    height: 22

    // Background
    Rectangle {
        anchors.fill: parent
        radius: Theme.settings.roundS
        color: Colors.colors.surface_container_highest
    }

    // Progress Fill
    Rectangle {
        id: fill
        height: parent.height - 4
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 2
        radius: Math.max(0, Theme.settings.roundS - 2)

        width: {
            let p = BatteryService.percentage;
            return Math.max(0, (parent.width - 4) * (p / 100));
        }

        color: {
            if (BatteryService.isCharging)
                return Colors.colors.tertiary;
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

    // Text & Icons
    RowLayout {
        anchors.centerIn: parent
        width: implicitWidth
        spacing: 2

        Text {
            text: BatteryService.isCharging ? "bolt" : (BatteryService.percentage < 20 ? "priority_high" : "")
            font.family: Theme.settings.fontFamilyMaterial
            font.pixelSize: 12
            color: BatteryService.percentage > 55 ? Colors.colors.on_primary : Colors.colors.on_surface
            visible: text !== ""
            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: BatteryService.percentage + "%"
            font.family: Theme.settings.fontFamily
            font.pixelSize: 10
            font.weight: Font.Bold
            color: BatteryService.percentage > 55 ? Colors.colors.on_primary : Colors.colors.on_surface

            Layout.alignment: Qt.AlignVCenter
            verticalAlignment: Text.AlignVCenter

            // Layout.topMargin: -1
        }
    }
}
