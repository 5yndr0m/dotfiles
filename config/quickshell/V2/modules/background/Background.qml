import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import "../../core"
import qs.components

PanelWindow {
    id: backgroundPanel

    signal requestControlPanel
    signal requestControlPanelLeft

    // We can use this property to push/pull elements when the panel is open
    property bool panelOpen: false
    property bool panelOpenLeft: false

    property var modelData
    screen: modelData || null

    color: "transparent"
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.keyboardFocus: WlrLayershell.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // --- Hot Zone Trigger ---
    Rectangle {
        id: sidebarTrigger
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 10
        color: "transparent"

        HoverHandler {
            id: triggerHandler
            onHoveredChanged: if (hovered)
                backgroundPanel.requestControlPanel()
        }
    }

    //this is for left side panel
    Rectangle {
        id: controlbarTrigger
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: 10
        color: "transparent"

        HoverHandler {
            id: controlHandler
            onHoveredChanged: if (hovered)
                backgroundPanel.requestControlPanelLeft()
        }
    }

    // --- Animated Corners ---
    ScreenCorners {
        id: corners
        cornerColor: Colors.colors.surface_container
        cornerRadius: Theme.settings.roundXL

        // Subtle fade when sidebar is active
        opacity: backgroundPanel.panelOpen ? 0.3 : 1.0

        Behavior on opacity {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }
    }

    // --- Animated Clock ---
    Clock {
        id: mainClock
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: Theme.settings.windowMarginXL
        anchors.bottomMargin: Theme.settings.windowMarginXL

        // Animate position: slide slightly left and fade out
        opacity: backgroundPanel.panelOpen ? 0.0 : 1.0

        transform: Translate {
            x: backgroundPanel.panelOpen ? -50 : 0
            Behavior on x {
                NumberAnimation {
                    duration: 450
                    easing.type: Easing.OutQuint
                }
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }
        }
    }

    // --- Animated Media Widget ---
    MediaWidget {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.settings.windowMarginXL
        anchors.bottomMargin: Theme.settings.windowMarginXL

        // Let's make this one just dim slightly
        opacity: backgroundPanel.panelOpen ? 0.5 : 1.0
        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }
        }
    }
}
