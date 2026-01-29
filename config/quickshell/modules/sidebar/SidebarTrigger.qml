import QtQuick

Rectangle {
    id: sidebarHotZone
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    width: 5
    height: parent.height
    color: "transparent"

    HoverHandler {
        onHoveredChanged: if (hovered)
            bg.requestControlPanel()
    }
}
