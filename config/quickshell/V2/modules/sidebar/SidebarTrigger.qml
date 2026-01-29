import QtQuick
import Quickshell

Rectangle {
    id: sidebarHotZone
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: 5 // Thin trigger
    height: parent.height
    color: "transparent"

    HoverHandler {
        onHoveredChanged: if (hovered)
            bg.requestControlPanel()
        // Note: In your Background.qml, this signal is already defined
    }
}
