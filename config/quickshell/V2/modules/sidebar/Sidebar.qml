import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.components
import "../../core"

PanelWindow {
    id: sidePanel

    anchors {
        right: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    margins {
        right: Theme.settings.windowMarginM
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
            // Reset the stack to the home view every time we open the panel
            mainStack.pop(null);
            visible = true;
        }
        closeTimer.stop();
    }

    Timer {
        id: closeTimer
        interval: 500
        onTriggered: if (!mainHover.hovered)
            sidePanel.closePanel()
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
        border.width: 0

        opacity: 0
        transform: Translate {
            id: slideTransform
            x: sidePanel.width
        }

        // --- STACK VIEW START ---
        StackView {
            id: mainStack
            anchors.fill: parent
            anchors.margins: Theme.settings.paddingL
            clip: true

            // The Default Dashboard View
            initialItem: ColumnLayout {
                spacing: Theme.settings.spacingL

                UserCard {
                    id: userProfile
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.colors.outline_variant
                    opacity: 0.3
                }

                QuickSettingsGrid {
                    id: quickSettings
                    // Push the WiFi list component onto the stack
                    onWifiClicked: mainStack.push(wifiListComponent)
                    // ADD BLUETOOTH NAVIGATION HERE
                    onBluetoothClicked: mainStack.push(bluetoothListComponent)
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.colors.outline_variant
                    opacity: 0.3
                }

                PowerProfileSwitch {
                    id: powerProfiles
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.colors.outline_variant
                    opacity: 0.3
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: Theme.settings.spacingM
                    spacing: Theme.settings.spacingS

                    VolumeSlider {}
                    BrightnessSlider {}
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Colors.colors.outline_variant
                    opacity: 0.3
                }

                MusicPlayer {}

                Item {
                    Layout.fillHeight: true
                }
            }
        }
    }

    // --- WIFI LIST COMPONENT ---
    Component {
        id: wifiListComponent
        WifiList {
            onBack: mainStack.pop()
        }
    }

    Component {
        id: bluetoothListComponent
        BluetoothList {
            onBack: mainStack.pop()
        }
    }

    // --- ANIMATIONS ---

    ParallelAnimation {
        id: showAnimation
        running: sidePanel.visible
        NumberAnimation {
            target: slideTransform
            property: "x"
            from: sidePanel.width
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
            to: sidePanel.width
            duration: 300
            easing.type: Easing.InCubic
        }
        NumberAnimation {
            target: panelRect
            property: "opacity"
            to: 0
            duration: 200
        }
        onFinished: sidePanel.visible = false
    }
}
