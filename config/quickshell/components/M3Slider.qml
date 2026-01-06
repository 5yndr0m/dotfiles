import QtQuick
import QtQuick.Layouts
import "../core"

ColumnLayout {
    id: sliderRoot

    property string icon: ""
    property string name: ""
    property real value: 0
    property color accentColor: Colors.colors.primary || "transparent"

    signal moved(real val)

    spacing: Theme.values.elementSpacingXS
    Layout.fillWidth: true

    RowLayout {
        Layout.fillWidth: true

        Text {
            text: sliderRoot.icon
            color: sliderRoot.accentColor || "transparent"
            font {
                family: Theme.values.fontFamilyMaterial
                pixelSize: Theme.values.iconSizeS
            }
        }

        Text {
            text: sliderRoot.name
            color: Colors.colors.on_surface || "transparent"
            font {
                family: Theme.values.fontFamily
                pixelSize: Theme.values.fontSize - 1
                bold: true
            }
        }

        Item {
            Layout.fillWidth: true
        }

        Text {
            text: Math.round(sliderRoot.value * 100) + "%"
            color: Colors.colors.on_surface_variant || "transparent"
            font {
                family: "Monospace"
                pixelSize: 11
                bold: true
            }
        }
    }

    Rectangle {
        id: track
        Layout.fillWidth: true
        height: 20
        radius: Theme.values.roundS
        color: Colors.colors.surface_container_highest || "transparent"

        Rectangle {
            id: fill
            width: track.width * sliderRoot.value
            height: parent.height
            radius: parent.radius
            color: sliderRoot.accentColor || "transparent"

            Behavior on width {
                NumberAnimation {
                    duration: 100
                }
            }
        }

        Rectangle {
            id: handle
            x: fill.width - (width / 2)
            anchors.verticalCenter: parent.verticalCenter

            width: sliderMouse.containsMouse || sliderMouse.pressed ? 16 : 0
            height: width
            radius: Theme.values.roundFull
            color: Colors.colors.on_primary || "transparent"

            border.width: 2
            border.color: sliderRoot.accentColor

            Behavior on width {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.OutCubic
                }
            }
        }

        MouseArea {
            id: sliderMouse
            anchors.fill: parent
            anchors.margins: -10
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            function updateValue(mouse) {
                let val = Math.max(0, Math.min(1, mouse.x / width));
                sliderRoot.moved(val);
            }

            onPressed: mouse => updateValue(mouse)
            onPositionChanged: mouse => {
                if (pressed)
                    updateValue(mouse);
            }
        }
    }
}
