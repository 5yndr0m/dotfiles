import QtQuick
import "../../core"

Rectangle {
    id: root
    width: Theme.values.barHeightS
    height: Theme.values.barHeightS
    radius: Theme.values.roundS
    color: mouseArea.containsMouse ? Colors.colors.surface_container_highest : "transparent"

    signal toggled

    Text {
        anchors.centerIn: parent
        text: "token"
        font.family: Theme.values.fontFamilyMaterial
        font.pixelSize: Theme.values.iconSizeM
        color: Colors.colors.primary
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.toggled()
    }
}
