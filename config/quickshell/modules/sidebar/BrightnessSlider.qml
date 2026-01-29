import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../core"

RowLayout {
    id: root
    spacing: Theme.settings.spacingM
    Layout.fillWidth: true

    Rectangle {
        width: 42
        height: 42
        radius: width / 2
        color: Colors.colors.surface_container_high

        Text {
            anchors.centerIn: parent
            text: BrightnessService.brightness > 50 ? "brightness_7" : (BrightnessService.brightness > 0 ? "brightness_4" : "brightness_empty")
            font.family: Theme.settings.fontFamilyMaterial
            font.pixelSize: 20
            color: Colors.colors.on_surface
        }
    }

    // Slider
    Slider {
        id: control
        Layout.fillWidth: true
        from: 0
        to: 100
        value: BrightnessService.brightness

        onMoved: {
            BrightnessService.set(Math.round(value));
        }

        background: Rectangle {
            x: control.leftPadding
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 200
            implicitHeight: 28
            width: control.availableWidth
            height: implicitHeight
            radius: 14
            color: Colors.colors.surface_container_high

            // Progress Fill
            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                color: Colors.colors.primary
                radius: 14
            }
        }

        handle: Rectangle {
            x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
            y: control.topPadding + control.availableHeight / 2 - height / 2
            implicitWidth: 4
            implicitHeight: 20
            radius: 2
            color: Colors.colors.on_primary
            visible: control.pressed
        }
    }

    // Percentage Label
    Text {
        Layout.preferredWidth: 35
        text: Math.round(BrightnessService.brightness) + "%"
        font.family: Theme.settings.fontFamily
        font.pixelSize: 12
        font.bold: true
        color: Colors.colors.on_surface_variant
        horizontalAlignment: Text.AlignRight
    }
}
