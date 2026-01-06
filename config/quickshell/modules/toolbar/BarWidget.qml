import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell.Io
import "../../core"

Rectangle {
    id: root

    width: 64
    height: column.implicitHeight + (Theme.values.paddingL * 2)

    color: Colors.colors.surface_container
    radius: Theme.values.roundXL

    layer.enabled: true
    layer.effect: DropShadow {
        radius: 12
        samples: 17
        color: Qt.rgba(0, 0, 0, 0.3)
        horizontalOffset: 4
        verticalOffset: 4
    }

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        spacing: Theme.values.spacingL
        width: 40

        ToolbarBtn {
            icon: "crop_free"
            command: "hyprshot -m region"
            tooltip: "Region"
        }

        ToolbarBtn {
            icon: "screenshot_monitor"
            command: "hyprshot -m output"
            tooltip: "Screen"
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.colors.outline
            opacity: 0.2
        }

        ToolbarBtn {
            icon: "monitoring"
            command: "foot btop"
            tooltip: "Btop"
        }

        ToolbarBtn {
            icon: "refresh"
            command: "sh -c 'pkill quickshell; quickshell'"
            tooltip: "Reload"
            accent: true
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.colors.outline
            opacity: 0.2
        }

        ToolbarBtn {
            icon: "lock"
            command: "hyprctl dispatch global quickshell:lockSession"
            tooltip: "Lock"
            btnColor: Colors.colors.error
        }
    }

    component ToolbarBtn: Item {
        id: btnRoot
        Layout.preferredWidth: 40
        Layout.preferredHeight: 40

        property string icon: ""
        property string command: ""
        property string tooltip: ""
        property color btnColor: Colors.colors.on_surface
        property bool accent: false

        Process {
            id: proc
            command: btnRoot.command.split(" ")
        }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: accent ? Colors.colors.primary : Colors.colors.on_surface
            opacity: hoverHandler.hovered ? (accent ? 1 : 0.1) : (accent ? 0.8 : 0)

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: btnRoot.icon
            font {
                family: Theme.values.fontFamilyMaterial
                pixelSize: 24
            }
            color: accent ? Colors.colors.on_primary : btnRoot.btnColor
        }

        HoverHandler {
            id: hoverHandler
            cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
            onTapped: if (btnRoot.command !== "")
                proc.running = true
        }

        ToolTip {
            visible: hoverHandler.hovered
            text: btnRoot.tooltip
            delay: 500
            contentItem: Text {
                text: btnRoot.tooltip
                color: Colors.colors.on_surface
                font.family: Theme.values.fontFamily
                padding: 4
            }
            background: Rectangle {
                color: Colors.colors.surface
                radius: 4
                border.width: 1
                border.color: Colors.colors.outline
            }
        }
    }
}
