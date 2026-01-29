import QtQuick
import "../../core"

Item {
    id: btn
    width: 140
    height: 160

    property string icon: ""
    property string label: ""
    property color color: Colors.colors.primary
    signal clicked

    Rectangle {
        id: card
        anchors.fill: parent
        radius: Theme.values.roundL
        color: hover.hovered ? Colors.colors.surface_container_high : Colors.colors.surface_container

        // Icon Circle
        Rectangle {
            width: 64
            height: 64
            radius: 32
            anchors.centerIn: parent
            anchors.verticalCenterOffset: -15
            color: hover.hovered ? btn.color : "transparent"
            border.width: 1
            border.color: btn.color

            Text {
                anchors.centerIn: parent
                text: btn.icon
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 32
                // Invert color on hover
                color: hover.hovered ? Colors.colors.surface : btn.color
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }
            }
        }

        // Label Text
        Text {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
            text: btn.label
            font.family: Theme.values.fontFamily
            font.pixelSize: 16
            font.bold: true
            color: Colors.colors.on_surface
        }

        // Hover Animation
        HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
        }
        TapHandler {
            onTapped: btn.clicked()
        }

        scale: hover.hovered ? 1.05 : 1.0
        Behavior on scale {
            NumberAnimation {
                duration: 150
            }
        }
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
