import QtQuick
import QtQuick.Layouts
import "../core"

Rectangle {
    id: root
    property string icon: ""
    property string label: ""
    property string status: ""
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

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12

        Text {
            text: root.icon
            font.family: Theme.settings.fontFamilyMaterial
            font.pixelSize: 24
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            color: root.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
        }

        ColumnLayout {
            spacing: 0
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter

            Text {
                text: root.status
                font.family: Theme.settings.fontFamily
                font.pixelSize: 10
                font.weight: Font.Bold
                opacity: 0.8
                color: root.isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant
            }

            Text {
                text: root.label
                font.family: Theme.settings.fontFamily
                font.pixelSize: 13
                font.weight: Font.DemiBold
                color: root.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
                elide: Text.ElideRight
            }
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
