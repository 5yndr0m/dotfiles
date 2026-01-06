import QtQuick
import QtQuick.Layouts
import Quickshell
import "../core"

Rectangle {
    id: mBtn

    property string icon: ""
    property int size: isPrimary ? 48 : 32
    property bool enabled: true
    property bool isPrimary: false
    signal clicked

    implicitWidth: size
    implicitHeight: size
    radius: Theme.values.roundFull

    color: {
        if (!isPrimary)
            return "transparent";
        return ma.containsMouse ? Colors.colors.primary || "transparent" : Colors.colors.primary_container || "transparent";
    }

    opacity: enabled ? 1.0 : 0.3

    Text {
        anchors.centerIn: parent
        text: mBtn.icon
        color: isPrimary ? Colors.colors.on_primary_container || "transparent" : (ma.containsMouse ? Colors.colors.primary || "transparent" : Colors.colors.on_surface_variant || "transparent")

        font {
            family: Theme.values.fontFamilyMaterial
            pixelSize: isPrimary ? Theme.values.iconSizeM : Theme.values.iconSizeS
        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (enabled)
            mBtn.clicked()
    }

    scale: ma.pressed ? 0.92 : (ma.containsMouse ? 1.08 : 1.0)

    Behavior on scale {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutBack
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }
}
