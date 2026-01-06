import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../core" // For Theme, Colors, Icons

Rectangle {
    id: root

    // Aesthetic container
    color: Colors.colors.surface_container_high
    radius: Theme.values.roundL
    clip: true

    // --- Background Blur Effect (Optional, adds a "glassy" feel using album art) ---
    Image {
        id: bgArt
        anchors.fill: parent
        source: MusicService.artUrl
        fillMode: Image.PreserveAspectCrop
        visible: false // Hidden, used as source for effect
    }
    FastBlur {
        anchors.fill: parent
        source: bgArt
        radius: 64
        opacity: 0.15 // Very subtle tint behind the controls
        visible: MusicService.artUrl !== ""
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 24
        spacing: 16

        // 1. Album Art (The Hero)
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: artContainer
                anchors.centerIn: parent
                // specific size logic: fit within available space but stay square
                height: Math.min(parent.height, parent.width)
                width: height

                radius: Theme.values.roundM
                color: Colors.colors.surface_container_highest // Placeholder color

                // Shadow
                layer.enabled: true
                layer.effect: DropShadow {
                    transparentBorder: true
                    horizontalOffset: 0
                    verticalOffset: 4
                    radius: 12
                    samples: 17
                    color: "#40000000"
                }

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: MusicService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: status === Image.Ready && MusicService.artUrl !== ""

                    // Round the image corners
                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: albumArt.width
                            height: albumArt.height
                            radius: Theme.values.roundM
                        }
                    }
                }

                // Fallback Icon if no art
                Text {
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: Theme.values.fontFamilyMaterial
                    font.pixelSize: 48
                    color: Colors.colors.on_surface_variant
                    opacity: 0.5
                    visible: !albumArt.visible
                }
            }
        }

        // 2. Metadata (Title & Artist)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: MusicService.title
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font {
                    family: Theme.values.fontFamily
                    pixelSize: 20
                    bold: true
                }
                color: Colors.colors.on_surface
                elide: Text.ElideRight
            }

            Text {
                text: MusicService.artist
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font {
                    family: Theme.values.fontFamily
                    pixelSize: 16
                }
                color: Colors.colors.secondary
                elide: Text.ElideRight
            }
        }

        // 3. Progress Bar
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 4
            color: Colors.colors.surface_container_highest
            radius: 2

            Rectangle {
                height: parent.height
                width: parent.width * MusicService.progress
                color: Colors.colors.primary
                radius: 2

                Behavior on width {
                    NumberAnimation {
                        duration: 1000
                    }
                }
            }
        }

        // 4. Controls
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 32

            // Previous
            Text {
                text: "skip_previous"
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 32
                color: MusicService.player ? Colors.colors.on_surface : Colors.colors.disabled

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (MusicService.player)
                        MusicService.player.previous()
                }
            }

            // Play/Pause (FAB Style)
            Rectangle {
                width: 56
                height: 56
                radius: 28
                color: Colors.colors.primaryContainer

                Text {
                    anchors.centerIn: parent
                    text: MusicService.isPlaying ? "pause" : "play_arrow"
                    font.family: Theme.values.fontFamilyMaterial
                    font.pixelSize: 32
                    color: Colors.colors.onPrimaryContainer
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MusicService.toggle()
                }

                // Subtle scale animation on click
                scale: pressed ? 0.95 : 1.0
                Behavior on scale {
                    NumberAnimation {
                        duration: 100
                    }
                }
            }

            // Next
            Text {
                text: "skip_next"
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 32
                color: MusicService.player ? Colors.colors.on_surface : Colors.colors.disabled

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (MusicService.player)
                        MusicService.player.next()
                }
            }
        }
    }
}
