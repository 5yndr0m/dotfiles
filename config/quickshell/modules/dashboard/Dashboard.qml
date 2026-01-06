import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../../core" // Assuming this contains Theme, Colors, SystemInfo

PanelWindow {
    id: dashboard

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    visible: false

    color: "transparent"

    GlobalShortcut {
        name: "DashboardToggle"
        onPressed: dashboard.toggle()
    }

    function toggle() {
        dashboard.visible = !dashboard.visible;
    }

    // Background Dimmer
    Rectangle {
        anchors.fill: parent
        color: "#80000000"
        MouseArea {
            anchors.fill: parent
            onClicked: dashboard.visible = false
        }
    }

    // Main Dashboard Content
    Loader {
        anchors.centerIn: parent
        active: dashboard.visible

        sourceComponent: Rectangle {
            width: 1000
            height: 600
            radius: Theme.values.roundXL
            color: Colors.colors.surface_container
            clip: true

            focus: true
            Component.onCompleted: forceActiveFocus()
            Keys.onEscapePressed: dashboard.visible = false

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 0

                // ==========================
                // COLUMN 1: LEFT (User & System)
                // ==========================
                ColumnLayout {
                    Layout.preferredWidth: 250
                    Layout.fillHeight: true
                    spacing: 20

                    // 1. User Info Component
                    DashUserInfo {
                        Layout.fillWidth: true
                    }

                    // 2. Separator (Optional visuals)
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Colors.colors.outline_variant
                        opacity: 0.3
                    }

                    // 3. System Monitor Component
                    DashSystemMonitor {
                        Layout.fillWidth: true
                        // It has an implicitHeight of 160, so it will size itself automatically
                    }

                    // Spacer to push everything up
                    Item {
                        Layout.fillHeight: true
                    }
                }

                // ==========================
                // DIVIDER 1
                // ==========================
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Layout.margins: 16
                    color: Colors.colors.outline_variant
                    opacity: 0.5
                }

                // ==========================
                // COLUMN 2: CENTER (Weather & Media)
                // ==========================
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.margins: 16
                    spacing: 16

                    // 1. Weather
                    DashWeather {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 80
                    }

                    // 2. Music Player (Replaces the placeholder)
                    DashMedia {
                        Layout.fillWidth: true
                        Layout.fillHeight: true // This will make it expand to fill the rest of the column
                    }
                }

                // ==========================
                // DIVIDER 2
                // ==========================
                Rectangle {
                    Layout.fillHeight: true
                    Layout.preferredWidth: 1
                    Layout.margins: 16
                    color: Colors.colors.outline_variant
                    opacity: 0.5
                }

                // ==========================
                // COLUMN 3: RIGHT (Placeholder)
                // ==========================
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredWidth: 250 // Match the width of the Left Column
                    spacing: 16

                    // 1. Top Processes Widget
                    DashTopProcesses {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                    }

                    // Optional: You could add a small "Quick Action" row below it later
                }
            }
        }
    }
}
