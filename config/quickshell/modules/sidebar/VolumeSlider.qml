import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
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
            text: AudioService.isMuted ? "volume_off" : (AudioService.volume > 50 ? "volume_up" : "volume_down")
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

        onMoved: {
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
