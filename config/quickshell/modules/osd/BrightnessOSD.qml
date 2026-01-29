import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../core"

PanelWindow {
    id: osdRoot

    property int position: 0

    property int brightnessValue: 0

    function show(value) {
        brightnessValue = value;
        osdRoot.visible = true;
        hideTimer.restart();
    }

    anchors.right: true
    anchors.top: position === 0 ? true : false
    anchors.bottom: position === 1 ? true : false

    margins.right: Theme.settings.windowMarginM
    margins.top: Theme.settings.windowMarginM
    margins.bottom: Theme.settings.windowMarginM + 50

    implicitWidth: 260
    implicitHeight: 64
    visible: false
    color: "transparent"

    // Auto-hide timer
    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: fadeOut.start()
    }

    // Smooth fade out
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

        radius: Theme.settings.roundXL

        RowLayout {
            anchors.fill: parent
            anchors.margins: Theme.settings.paddingL
            spacing: Theme.settings.spacingM

            Text {
                text: BrightnessService.brightness > 50 ? "brightness_7" : (BrightnessService.brightness > 0 ? "brightness_4" : "brightness_empty")
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: Theme.settings.iconSizeM

                color: Colors.colors.on_surface
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 12

                radius: Theme.settings.roundS

                color: Colors.colors.surface_container_high
                clip: true

                Rectangle {
                    width: parent.width * (osdRoot.brightnessValue / 100)
                    height: parent.height
                    radius: Theme.settings.roundS

                    color: Colors.colors.primary

                    Behavior on width {
                        NumberAnimation {
                            duration: 150
                            easing.type: Easing.OutQuad
                        }
                    }
                }
            }

            Text {
                text: osdRoot.brightnessValue + "%"
                font.family: Theme.settings.fontFamily
                font.pixelSize: Theme.settings.fontSize
                font.bold: true

                color: Colors.colors.on_surface

                Layout.preferredWidth: 35
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}
