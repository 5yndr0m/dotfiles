import QtQuick
import QtQuick.Layouts
import "../core"

ColumnLayout {
    id: sliderRoot

    property real value: 0
    property color accentColor: Colors.colors.primary || "transparent"

    signal moved(real val)

    spacing: 0
    Layout.fillWidth: true

    Rectangle {
        id: track
        Layout.fillWidth: true
        height: 4
        radius: Theme.values.roundFull
        color: Colors.colors.outline_variant || "transparent"
        opacity: 0.4

        Rectangle {
            id: fill
            width: track.width * sliderRoot.value
            height: parent.height
            radius: parent.radius
            color: sliderRoot.accentColor || "transparent"

            Behavior on width {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.Linear
                }
            }
        }

        Rectangle {
            id: handle
            x: fill.width - (width / 2)
            anchors.verticalCenter: parent.verticalCenter
            width: sliderMouse.containsMouse || sliderMouse.pressed ? 10 : 0
            height: 10
            radius: Theme.values.roundFull
            color: sliderRoot.accentColor || "transparent"

            Behavior on width {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        MouseArea {
            id: sliderMouse
            anchors.fill: parent
            anchors.topMargin: -10
            anchors.bottomMargin: -10
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
