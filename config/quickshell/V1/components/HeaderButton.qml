import QtQuick
import "../core"

Rectangle {
    id: root

    property string icon: ""
    property color accentColor: Colors.colors.primary || "transparent"
    signal clicked

    width: 36
    height: 36
    radius: Theme.values.roundS

    color: btnMouse.containsMouse ? Colors.colors.surface_container_highest || "transparent" : Colors.colors.surface_container_high || "transparent"

    Text {
        anchors.centerIn: parent
        text: root.icon
        color: root.accentColor
        font {
            family: Theme.values.fontFamilyMaterial
            pixelSize: Theme.values.iconSizeS
        }
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}
