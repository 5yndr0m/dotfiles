import QtQuick
import Quickshell
import "../../core"

Text {
    id: root
    color: Colors.colors.on_surface
    font {
        family: Theme.values.fontFamily
        pixelSize: 13
        weight: Font.Medium
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    text: Qt.formatDateTime(clock.date, "ddd, MMM dd  HH:mm")
}
