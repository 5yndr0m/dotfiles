import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../core"
import qs.components

PanelWindow {
    id: root

    anchors {
        bottom: true
        right: true
    }
    margins {
        right: 48
        bottom: 0
    }

    implicitWidth: 360
    implicitHeight: 160
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Overlay

    mask: Region {
        item: activeZone
    }

    Item {
        id: activeZone
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        height: root.show ? parent.height : 10
    }

    property bool show: mainHover.hovered

    HoverHandler {
        id: mainHover
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        cursorShape: Qt.PointingHandCursor
    }

    MusicWidget {
        id: widget

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        anchors.bottomMargin: root.show ? 20 : -height - 10
        opacity: root.show ? 1.0 : 0.0

        Behavior on anchors.bottomMargin {
            NumberAnimation {
                duration: 400
                easing.type: Easing.OutCubic
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
            }
        }
    }
}
