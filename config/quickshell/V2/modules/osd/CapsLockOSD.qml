import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../core"

PanelWindow {
    id: osdRoot

    property bool capsActive: false

    function show(active) {
        capsActive = active;
        osdRoot.visible = true;
        hideTimer.restart();
    }

    // anchors.centerIn: parent // Caps lock usually looks better in the center

    // Smaller size for simple notification
    implicitWidth: 180
    implicitHeight: 50
    visible: false
    color: "transparent"

    Timer {
        id: hideTimer
        interval: 1500
        onTriggered: fadeOut.start()
    }

    NumberAnimation {
        id: fadeOut
        target: background
        property: "opacity"
        to: 0
        duration: 300
        onFinished: osdRoot.visible = false
    }

    onVisibleChanged: if (visible)
        background.opacity = 1

    Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.colors.surface_container
        radius: Theme.settings.roundXL
        border.width: 1
        border.color: Colors.colors.outline_variant

        RowLayout {
            anchors.centerIn: parent
            spacing: Theme.settings.spacingM

            Text {
                text: osdRoot.capsActive ? "keyboard_capslock" : "lock_open"
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: Theme.settings.iconSizeM
                color: Colors.colors.primary
            }

            Text {
                text: osdRoot.capsActive ? "CAPS LOCK ON" : "Caps Lock Off"
                font.family: Theme.settings.fontFamily
                font.pixelSize: Theme.settings.fontSize
                font.bold: true
                color: Colors.colors.on_surface
            }
        }
    }
}
