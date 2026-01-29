import QtQuick
import QtQuick.Controls
import "../core"

Control {
    id: root
    property string iconText: ""

    signal actionClicked

    implicitWidth: 32
    implicitHeight: 32

    // The Background
    background: Rectangle {
        radius: Theme.settings.roundM
        color: root.hovered ? Colors.colors.primary : Colors.colors.surface_container_high

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    // The Icon
    contentItem: Text {
        text: root.iconText
        font.family: Theme.settings.fontFamilyMaterial
        font.pixelSize: Theme.settings.iconSizeM
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: root.hovered ? Colors.colors.surface : Colors.colors.on_surface

        Behavior on color {
            ColorAnimation {
                duration: 200
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            console.log("ActionButton: MouseArea clicked");
            root.actionClicked();
        }
    }
}
