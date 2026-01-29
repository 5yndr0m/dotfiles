import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../core"

Item {
    id: root
    implicitWidth: content.width
    implicitHeight: content.height

    SystemClock {
        id: sysClock
        precision: SystemClock.Minutes
    }

    ColumnLayout {
        id: content
        spacing: -Theme.settings.spacingL

        Text {
            text: Qt.formatDateTime(sysClock.date, "HH:mm")
            font.family: Theme.settings.fontFamily
            font.pixelSize: 84
            font.weight: Font.Bold
            color: Colors.colors.primary_fixed
            Layout.alignment: Qt.AlignRight
        }

        Text {
            text: Qt.formatDateTime(sysClock.date, "dddd, dd/MM")
            font.family: Theme.settings.fontFamily
            font.pixelSize: 22
            font.weight: Font.DemiBold
            color: Colors.colors.primary_fixed
            opacity: 0.8
            Layout.alignment: Qt.AlignRight
        }
    }
}
