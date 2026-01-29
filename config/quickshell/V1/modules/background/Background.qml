import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../core"
import qs.components

PanelWindow {
    id: bg

    signal requestControlPanel
    property var modelData
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrLayershell.None

    Rectangle {
        id: controlPanelHotZone
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: 10
        height: parent.height / 2
        color: "transparent" // Debug: "#55ff0000"

        HoverHandler {
            cursorShape: Qt.PointingHandCursor
            onHoveredChanged: if (hovered)
                bg.requestControlPanel()
        }
    }

    CornerShape {
        id: topleftCorner
        width: 48
        height: 48
        anchors.left: parent.left
        anchors.top: parent.top
        color: Colors.colors.surface_container
        radius: 32
        orientation: 0 // Top Left
    }

    CornerShape {
        id: toprightCorner
        width: 48
        height: 48
        anchors.right: parent.right
        anchors.top: parent.top
        color: Colors.colors.surface_container
        radius: 32
        orientation: 1 // Top Right
    }

    CornerShape {
        id: bottomleftCorner
        width: 48
        height: 48
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        color: Colors.colors.surface_container
        radius: 32
        orientation: 2 // Bottom Left
    }

    CornerShape {
        id: bottomrightCorner
        width: 48
        height: 48
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        color: Colors.colors.surface_container
        radius: 32
        orientation: 3 // Bottom Right
    }

    Rectangle {
        id: gradient
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 1.0
                color: Qt.rgba(0, 0, 0, 0.6)
            }
        }
    }
}
