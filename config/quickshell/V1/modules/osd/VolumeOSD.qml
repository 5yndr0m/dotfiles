import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../../core"

PanelWindow {
    id: osdRoot

    property int volumeValue: 0
    property bool isMuted: false

    // 0 = Top Right, 1 = Bottom Right
    property int position: 0

    function show(vol, muted) {
        volumeValue = vol;
        isMuted = muted;
        osdRoot.visible = true;
        hideTimer.restart();
    }

    anchors.right: true
    anchors.top: position === 0 ? true : false
    anchors.bottom: position === 1 ? true : false
    margins.right: Theme.values.windowMarginM
    margins.top: Theme.values.windowMarginM
    margins.bottom: Theme.values.windowMarginM + 50

    implicitWidth: 260
    implicitHeight: 64
    visible: false
    color: "transparent"

    Timer {
        id: hideTimer
        interval: 2000
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

    onVisibleChanged: {
        if (visible)
            background.opacity = 1;
    }

    Rectangle {
        id: background
        anchors.fill: parent
        color: Colors.colors.surface_container
        radius: Theme.values.roundXL
        border.width: 1
        border.color: Colors.colors.outline_variant

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.values.paddingL
            spacing: Theme.values.spacingM

            // Icon changes based on volume/mute
            Text {
                text: osdRoot.isMuted ? "volume_off" : (osdRoot.volumeValue > 50 ? "volume_up" : "volume_down")
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: Theme.values.iconSizeM
                color: osdRoot.isMuted ? Colors.colors.error : Colors.colors.on_surface
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                radius: Theme.values.roundS
                color: Colors.colors.surface_container_high
                clip: true

                Rectangle {
                    width: Math.min(parent.width * (osdRoot.volumeValue / 100), parent.width)
                    height: parent.height
                    radius: Theme.values.roundS
                    // Change color if muted
                    color: osdRoot.isMuted ? Colors.colors.error : Colors.colors.primary

                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            Text {
                text: osdRoot.volumeValue + "%"
                font.family: Theme.values.fontFamily
                font.pixelSize: Theme.values.fontSize
                font.bold: true
                color: Colors.colors.on_surface
                Layout.preferredWidth: 35
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
