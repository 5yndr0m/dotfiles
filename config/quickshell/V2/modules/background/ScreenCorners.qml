import QtQuick
import "../../core"
import qs.components

Item {
    id: root
    anchors.fill: parent

    // Optional: add a property to easily change color/radius for all corners at once
    property color cornerColor: Colors.colors.surface_container
    property int cornerRadius: 32
    property int cornerSize: 48

    CornerShape {
        anchors.left: parent.left
        anchors.top: parent.top
        width: root.cornerSize
        height: root.cornerSize
        color: root.cornerColor
        radius: root.cornerRadius
        orientation: 0
    }

    CornerShape {
        anchors.right: parent.right
        anchors.top: parent.top
        width: root.cornerSize
        height: root.cornerSize
        color: root.cornerColor
        radius: root.cornerRadius
        orientation: 1
    }

    CornerShape {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: root.cornerSize
        height: root.cornerSize
        color: root.cornerColor
        radius: root.cornerRadius
        orientation: 2
    }

    CornerShape {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: root.cornerSize
        height: root.cornerSize
        color: root.cornerColor
        radius: root.cornerRadius
        orientation: 3
    }
}
