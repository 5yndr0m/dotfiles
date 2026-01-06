import Quickshell
import Quickshell.Services.Pipewire
import QtQuick
import QtQuick.Layouts
import qs.components
import "../../core"

PanelWindow {
    id: controlPanel

    anchors {
        top: true
        right: true
    }

    margins {
        top: Theme.values.windowMarginM
        right: Theme.values.windowMarginM
    }

    color: "transparent"
    visible: false

    implicitWidth: 350
    implicitHeight: 520

    // signal closed

    function closePanel() {
        if (visible && !hideAnimation.running) {
            shouldBeVisible = false;
            hideAnimation.start();
        }
    }

    function openPanel() {
        if (!visible) {
            visible = true;
        }
        closeTimer.stop();
    }

    function toggle() {
        if (visible && !hideAnimation.running) {
            closePanel();
        } else {
            openPanel();
        }
    }

    Shortcut {
        sequence: "Esc"
        onActivated: controlPanel.closePanel()
    }

    HoverHandler {
        id: mainHover
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop();
            } else {
                closeTimer.start();
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        hoverEnabled: false
        onPressed: mouse => mouse.accepted = true
    }

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: {
            if (!mainHover.hovered) {
                controlPanel.closePanel();
            }
        }
    }

    property bool shouldBeVisible: false

    onVisibleChanged: {
        if (visible) {
            shouldBeVisible = true;
            showAnimation.start();
        }
    }

    Rectangle {
        id: panelRect
        anchors.fill: parent

        color: Colors.colors.surface_container
        radius: Theme.values.roundXL

        opacity: 0
        scale: 0.95
        transform: Translate {
            id: slideTransform
            x: 330
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.values.paddingL
            spacing: Theme.values.spacingL

            ControlHeader {
                id: header
                Layout.fillWidth: true
            }

            MenuDivider {}

            PowerProfileSwitch {
                id: powerProfileSwitch
                Layout.fillWidth: true
            }

            QuickSettingsGrid {
                id: quickSettingsGrid
                Layout.fillWidth: true
            }

            MenuDivider {}

            ControlVolume {
                id: volumeControl
                Layout.fillWidth: true
            }

            Item {
                Layout.fillHeight: true
            }
        }
    }

    component MenuDivider: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.leftMargin: Theme.values.paddingS
        Layout.rightMargin: Theme.values.paddingS
        color: Colors.colors.outline_variant
        opacity: 0.5
    }

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
            easing.type: Easing.OutBack
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
            controlPanel.visible = false;
            controlPanel.closed();
        }
    }
}
