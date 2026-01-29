import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../core"

PanelWindow {
    id: leftPanel

    anchors {
        left: true // Mirror: Left instead of Right
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    margins {
        left: Theme.settings.windowMarginM
    }

    color: "transparent"
    visible: false

    implicitWidth: 350
    implicitHeight: 675

    function closePanel() {
        if (visible && !hideAnimation.running)
            hideAnimation.start();
    }

    function openPanel() {
        if (!visible) {
            visible = true;
        }
        closeTimer.stop();
    }

    Timer {
        id: closeTimer
        interval: 500
        onTriggered: if (!mainHover.hovered)
            leftPanel.closePanel()
    }

    HoverHandler {
        id: mainHover
        onHoveredChanged: hovered ? closeTimer.stop() : closeTimer.start()
    }

    Rectangle {
        id: panelRect
        anchors.fill: parent
        color: Colors.colors.surface_container
        radius: Theme.settings.roundXL

        opacity: 0
        transform: Translate {
            id: slideTransform
            x: -leftPanel.width // Mirror: Starts off-screen to the left
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.settings.paddingL
            spacing: Theme.settings.spacingL

            // --- BAR WIDGET START ---
            BarWidget {
                id: barWidget
                Layout.fillWidth: true
                // Since BarWidget has its own height calculation,
                // we let it dictate its preferred height in the layout.
                Layout.preferredHeight: implicitHeight
            }
            // --- BAR WIDGET END ---

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.colors.outline_variant
                opacity: 0.3
            }

            SystemMonitor {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Colors.colors.outline_variant
                opacity: 0.3
            }

            NotificationCenter {
                Layout.fillHeight: true
            }

            // Spacer to push content to the top
            Item {
                Layout.fillHeight: true
            }
        }
    }

    // --- ANIMATIONS ---
    ParallelAnimation {
        id: showAnimation
        running: leftPanel.visible
        NumberAnimation {
            target: slideTransform
            property: "x"
            from: -leftPanel.width
            to: 0
            duration: 400
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: panelRect
            property: "opacity"
            from: 0
            to: 1
            duration: 300
        }
    }

    ParallelAnimation {
        id: hideAnimation
        NumberAnimation {
            target: slideTransform
            property: "x"
            to: -leftPanel.width
            duration: 300
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: panelRect
            property: "opacity"
            to: 0
            duration: 200
        }
        onFinished: leftPanel.visible = false
    }
}
