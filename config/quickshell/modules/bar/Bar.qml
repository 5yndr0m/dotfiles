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

    implicitHeight: Theme.settings.barHeightS
    color: Colors.colors.surface_container

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.exclusionMode: ExclusionMode.Auto

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.settings.spacingM
        anchors.rightMargin: Theme.settings.spacingM
        spacing: Theme.settings.spacingL // Space between groups

        // --- Left Side ---
        Row {
            Layout.alignment: Qt.AlignVCenter
            spacing: Theme.settings.spacingM

            SystemLogo {
                Layout.alignment: Qt.AlignVCenter
            }

            Workspaces {}
        }

        // --- Center ---
        Item {
            Layout.fillWidth: true
        }

        Clock {
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            Layout.fillWidth: true
        }

        // --- Right Side ---

        Tray {
            barWindow: barRoot
        }

        BatteryPill {
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
