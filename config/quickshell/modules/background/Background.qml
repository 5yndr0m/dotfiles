import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../core"

PanelWindow {
    id: backgroundPanel

    signal requestControlPanel
    property var modelData
    screen: modelData || null

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Hot Zone Trigger
    Rectangle {
        id: sidebarTrigger
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 10
        color: "transparent"
        HoverHandler {
            onHoveredChanged: if (hovered)
                backgroundPanel.requestControlPanel()
        }
    }

    ScreenCorners {
        cornerColor: Colors.colors.surface_container
        cornerRadius: Theme.settings.roundXL
    }

    // --- Stacked Widgets ---
    ColumnLayout {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.settings.windowMarginXL
        anchors.bottomMargin: Theme.settings.windowMarginXL
        spacing: 12

        Clock {
            id: mainClock
        }

        MediaWidget {
            id: media
        }
    }
}
