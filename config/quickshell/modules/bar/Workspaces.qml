import QtQuick
import QtQuick.Layouts
import Quickshell.Hyprland
import "../../core"

RowLayout {
    spacing: Theme.values.spacingS

    Rectangle {
        width: workspaceIdText.width + 8
        height: parent.height - 8
        color: Colors.colors.primary_container
        radius: 4
        visible: Hyprland.focusedWorkspace !== null

        Text {
            id: workspaceIdText
            anchors.centerIn: parent
            text: Hyprland.focusedWorkspace?.id || "1"
            color: Colors.colors.on_primary_container
            font {
                family: Theme.values.fontFamily
                pixelSize: 10
                weight: Font.Black
            }
        }
    }

    Text {
        text: Hyprland.activeToplevel?.title || "System Ready"
        color: Colors.colors.on_surface
        font {
            family: Theme.values.fontFamily
            pixelSize: 11
            weight: Font.Medium
        }
        elide: Text.ElideRight
        Layout.maximumWidth: 250
        verticalAlignment: Text.AlignVCenter
    }
}
