import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../core"

RowLayout {
    id: root
    spacing: Theme.settings.spacingM
    Layout.fillWidth: true

    // Mute/Unmute Button
    Rectangle {
        width: 42
        height: 42
        radius: width / 2
        color: AudioService.isMuted ? Colors.colors.error_container : Colors.colors.surface_container_high

        Text {
            anchors.centerIn: parent
            text: AudioService.isMuted ? "\ue04f" : (AudioService.volume > 50 ? "\ue050" : "\ue04d")
            font.family: Theme.settings.fontFamilyMaterial
            font.pixelSize: 20
            color: AudioService.isMuted ? Colors.colors.on_error_container : Colors.colors.on_surface
        }

        MouseArea {
            anchors.fill: parent
            onClicked: AudioService.toggleMute()
        }
    }

    // Slider
    Slider {
        id: control
        Layout.fillWidth: true
        from: 0
        to: 100
        value: AudioService.volume

        // This handles sliding
        onMoved: {
            // wpctl expects decimals or percentages.
            // We'll send it as a set value: "0.45"
            let targetVol = (value / 100).toFixed(2);
            AudioService.exec(["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", targetVol]);
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

            Rectangle {
                width: control.visualPosition * parent.width
                height: parent.height
                color: AudioService.isMuted ? Colors.colors.outline : Colors.colors.primary
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

    // Volume Percentage Label
    Text {
        Layout.preferredWidth: 35
        text: AudioService.volume + "%"
        font.family: Theme.settings.fontFamily
        font.pixelSize: 12
        font.bold: true
        color: Colors.colors.on_surface_variant
        horizontalAlignment: Text.AlignRight
    }
}
