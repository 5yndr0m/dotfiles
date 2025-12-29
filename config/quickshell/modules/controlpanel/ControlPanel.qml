// ControlPanel.qml
import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.config
import qs.Components

PanelWindow {
    id: controlPanel

    anchors.top: true
    anchors.right: true

    // Keep window transparent to show rounded corners of the inner rectangle
    color: "transparent"
    visible: false

    implicitWidth: 340
    implicitHeight: 650

    // Small offset from the screen edges for a floating look
    margins.top: 12
    margins.right: 12

    property bool shouldBeVisible: false

    function toggle() {
        controlPanel.visible = !controlPanel.visible;
    }

    onVisibleChanged: {
        if (visible) {
            shouldBeVisible = true;
            showAnimation.start();
        } else if (shouldBeVisible) {
            shouldBeVisible = false;
            hideAnimation.start();
        }
    }

    // Dismiss panel when clicking outside (in the transparent window area)
    MouseArea {
        anchors.fill: parent
        z: -1
        onClicked: controlPanel.visible = false
    }

    Rectangle {
        id: panelRect
        anchors.fill: parent

        color: ThemeAuto.bgSurface
        radius: 24 // More rounded M3 radius

        border.width: 1
        border.color: ThemeAuto.outline

        opacity: 0
        scale: 0.95

        transform: Translate {
            id: slideTransform
            x: 330
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            ControlHeader {
                id: header
                Layout.fillWidth: true
            }

            ControlVolume {
                id: volumeControl
                Layout.fillWidth: true
            }

            ControlQuickActions {
                id: quickActions
                Layout.fillWidth: true
            }

            ControlNowPlaying {
                id: nowPlaying
                Layout.fillWidth: true
                // Note: This matches the widget we just color-swapped
            }

            ControlSystemMonitor {
                id: systemMonitor
                Layout.fillWidth: true
            }

            ControlWeather {
                id: weather
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            } // Spacer
        }
    }

    // --- Animations ---

    ParallelAnimation {
        id: showAnimation

        NumberAnimation {
            target: slideTransform
            property: "x"
            from: 330
            to: 0
            duration: 350
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panelRect
            property: "opacity"
            from: 0
            to: 1
            duration: 250
            easing.type: Easing.OutCubic
        }

        NumberAnimation {
            target: panelRect
            property: "scale"
            from: 0.95
            to: 1.0
            duration: 350
            easing.type: Easing.OutBack // Added a tiny bit of "pop"
        }
    }

    ParallelAnimation {
        id: hideAnimation

        NumberAnimation {
            target: slideTransform
            property: "x"
            to: 330
            duration: 250
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: panelRect
            property: "opacity"
            to: 0
            duration: 200
            easing.type: Easing.InCubic
        }

        NumberAnimation {
            target: panelRect
            property: "scale"
            to: 0.95
            duration: 250
            easing.type: Easing.InCubic
        }

        onFinished: {
            if (!shouldBeVisible) {
                controlPanel.visible = false;
            }
        }
    }
}
