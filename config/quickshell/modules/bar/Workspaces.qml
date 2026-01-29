import QtQuick
// import QtQuick.Layouts
// import Quickshell
import Quickshell.Hyprland
import "../../core"

Row {
    id: root
    spacing: Theme.settings.spacingS

    anchors.verticalCenter: parent ? parent.verticalCenter : undefined

    Repeater {
        model: Hyprland.workspaces

        Rectangle {
            id: dot

            property var ws: modelData
            property bool isActive: Hyprland.focusedWorkspace === ws

            height: 8
            width: isActive ? 24 : 8
            radius: Theme.settings.roundFull

            color: {
                if (isActive)
                    return Colors.colors.primary;
                return Colors.colors.surface_variant;
            }

            border.color: Colors.colors.outline_variant
            border.width: (ws.windows > 0 && !isActive) ? 1 : 0

            Behavior on width {
                NumberAnimation {
                    duration: 300
                    easing.type: Easing.OutQuint
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: ws.focus()
            }
        }
    }
}
