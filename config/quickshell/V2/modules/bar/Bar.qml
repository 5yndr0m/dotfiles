import Quickshell
import Quickshell.Wayland
import QtQuick.Layouts
import QtQuick
import qs.components

import "../../core"

PanelWindow {
    id: barRoot

    property var modelData
    screen: modelData || null

    anchors {
        top: true
        left: true
        right: true
    }

    // Use height instead of implicitHeight for the bar to ensure it's fixed
    implicitHeight: Theme.settings.barHeightS
    color: Colors.colors.surface_container

    // WlrLayershell.layer: WlrLayer.Top

    // Layout container to handle centering and alignment
    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.settings.spacingM
        anchors.rightMargin: Theme.settings.spacingM
        spacing: Theme.settings.spacingL // Space between groups

        // --- Left Side ---
        Row {
            // This is the key: tell the Row to sit in the center of the RowLayout's height
            Layout.alignment: Qt.AlignVCenter
            spacing: Theme.settings.spacingM

            SystemLogo {
                // Logo is already VCenter by default if size is set,
                // but explicit alignment never hurts
                Layout.alignment: Qt.AlignVCenter
            }

            // Ensure the Workspaces row also aligns its children internally
            // (already true for simple Rows usually, but good to be explicit)
            Workspaces {}
        }

        // --- Center ---
        // This spacer pushes the clock to the middle
        Item {
            Layout.fillWidth: true
        }

        Clock {
            Layout.alignment: Qt.AlignVCenter
        }

        // This second spacer keeps the clock centered between the left/right groups
        Item {
            Layout.fillWidth: true
        }

        Tray {
            barWindow: barRoot
        }

        // --- Right Side ---
        BatteryPill {
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
