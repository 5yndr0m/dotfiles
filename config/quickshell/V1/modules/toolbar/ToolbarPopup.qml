import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../core"

PanelWindow {
    id: root

    anchors {
        left: true
        top: true
        bottom: true
    }

    implicitWidth: 120
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusiveZone: -1

    mask: Region {
        item: activeZone
    }

    Item {
        id: activeZone
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: root.show ? parent.width : 10
    }

    property bool show: mainHover.hovered

    HoverHandler {
        id: mainHover
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        cursorShape: Qt.PointingHandCursor
    }

    BarWidget {
        id: widget
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: root.show ? 20 : -width - 20
        opacity: root.show ? 1.0 : 0.0

        Behavior on anchors.leftMargin {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity {
            NumberAnimation {
                duration: 200
            }
        }
    }
}
