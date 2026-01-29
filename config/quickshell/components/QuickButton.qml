import QtQuick
import QtQuick.Layouts
import "../core"

Rectangle {
    id: root

    property string icon: ""
    property string label: ""
    property bool isActive: false
    signal clicked

    implicitHeight: 60
    radius: Theme.settings.roundM

    color: isActive ? (hover.hovered ? Colors.colors.primary_fixed : Colors.colors.primary) : (hover.hovered ? Colors.colors.surface_container_highest : Colors.colors.surface_container_high)

    Behavior on color {
        ColorAnimation {
            duration: 200
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 4

        Text {
            text: root.icon
            font.family: Theme.settings.fontFamilyMaterial
            font.pixelSize: 24
            color: root.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            horizontalAlignment: Text.AlignHCenter
        }

        Text {
            text: root.label
            font.family: Theme.settings.fontFamily
            font.pixelSize: 11
            font.weight: Font.Medium
            color: root.isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            horizontalAlignment: Text.AlignHCenter
        }
    }

    HoverHandler {
        id: hover
    }
    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
        cursorShape: Qt.PointingHandCursor
    }
}
