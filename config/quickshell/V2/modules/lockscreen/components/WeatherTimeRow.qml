import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../core"

Item {
    id: timeRoot
    Layout.fillWidth: true
    Layout.preferredHeight: 160

    property var colors
    property var tokens

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: -20

        Text {
            text: Qt.formatDateTime(clock.date, "HH:mm")
            color: colors.on_surface
            font {
                family: tokens.fontFamily
                pixelSize: 128
                weight: Font.Bold
            }
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: Qt.formatDateTime(clock.date, "dddd, MMMM dd")
            color: colors.on_surface_variant
            font {
                family: tokens.fontFamily
                pixelSize: 24
                weight: Font.Medium
                letterSpacing: 1.5
            }
            Layout.alignment: Qt.AlignHCenter
            opacity: 0.9
        }
    }
}
