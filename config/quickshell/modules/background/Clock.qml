import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../core"

Item {
    id: root
    implicitWidth: 340
    implicitHeight: background.height

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    Rectangle {
        id: background
        width: parent.width
        height: content.implicitHeight
        color: Colors.colors.surface_container
        radius: Theme.settings.roundXL

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.topMargin: -8
            anchors.bottomMargin: 10
            anchors.rightMargin: 24
            anchors.leftMargin: 24
            spacing: -30

            Text {
                Layout.fillWidth: true
                text: Qt.formatDateTime(sysClock.date, "HH:mm")
                font.family: Theme.settings.fontFamily
                font.pixelSize: 108
                font.weight: Font.Bold
                color: Colors.colors.primary_fixed
                horizontalAlignment: Text.AlignRight
                lineHeight: 0.8
            }

            Text {
                Layout.fillWidth: true
                text: Qt.formatDateTime(sysClock.date, "dddd, dd/MM")
                font.family: Theme.settings.fontFamily
                font.pixelSize: 32
                font.weight: Font.DemiBold
                color: Colors.colors.primary_fixed
                opacity: 0.8
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
