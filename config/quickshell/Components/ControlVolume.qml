import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.config

Rectangle {
    id: controlVolume

    implicitWidth: parent.width - 10
    implicitHeight: 120

    border.width: 2
    border.color: ThemeAuto.outline // Changed from Theme.surface2
    radius: 8
    color: ThemeAuto.bgSurface    // Changed from Theme.crust

    // Audio service tracker
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 16

        // --- SPEAKER ROW ---
        VolumeRow {
            audioObject: Pipewire.defaultAudioSink
            icon: (audioObject?.audio?.muted) ? "volume_off" : "volume_up"
            accentColor: ThemeAuto.accent // Changed from Theme.blue
        }

        // --- MICROPHONE ROW ---
        VolumeRow {
            audioObject: Pipewire.defaultAudioSource
            icon: (audioObject?.audio?.muted) ? "mic_off" : "mic"
            accentColor: ThemeAuto.accent // Changed from Theme.mauve
        }
    }

    // Helper component for a volume row
    component VolumeRow: RowLayout {
        property var audioObject
        property string icon
        property color accentColor

        spacing: 12
        Layout.fillWidth: true

        // Icon (clickable to toggle mute)
        Text {
            text: icon
            color: accentColor
            font {
                family: "Material Symbols Rounded"
                pixelSize: 18
            }
            Layout.preferredWidth: 24

            // Visual feedback on hover
            opacity: iconMouseArea.containsMouse ? 0.7 : 1.0

            MouseArea {
                id: iconMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (audioObject && audioObject.audio) {
                        audioObject.audio.muted = !audioObject.audio.muted;
                    }
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }
        }

        // The "Slider" (Progress Bar)
        Rectangle {
            id: sliderBg
            Layout.fillWidth: true
            height: 8
            radius: 4
            color: ThemeAuto.bgContainer // Changed from Theme.surface0

            Rectangle {
                id: sliderFill
                width: parent.width * (audioObject?.audio?.volume || 0)
                height: parent.height
                radius: parent.radius
                color: accentColor

                Behavior on width {
                    NumberAnimation {
                        duration: 150
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: mouse => {
                    if (audioObject && audioObject.audio) {
                        let newVol = mouse.x / width;
                        audioObject.audio.volume = newVol;
                    }
                }
            }
        }

        // Percentage Text
        Text {
            text: Math.round((audioObject?.audio?.volume || 0) * 100) + "%"
            color: ThemeAuto.textMain // Changed from Theme.text
            font {
                family: Theme.fontFamily
                pixelSize: Theme.fontSize - 2
            }
            Layout.preferredWidth: 35
        }
    }
}
