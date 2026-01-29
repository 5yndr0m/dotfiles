import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import "../../core"

Rectangle {
    id: musicCard
    Layout.fillWidth: true
    implicitHeight: 110
    radius: Theme.settings.roundM
    color: Colors.colors.surface_container_highest

    ClippingRectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"

        // --- Background Blurred Album Art ---
        Image {
            anchors.fill: parent
            source: MusicService.artUrl || ""
            fillMode: Image.PreserveAspectCrop
            opacity: 0.12
            visible: MusicService.artUrl !== ""
        }

        // --- Main Two-Column Layout ---
        RowLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 16

            // --- COLUMN 1: Album Art Thumbnail ---
            Rectangle {
                Layout.preferredWidth: 84
                Layout.preferredHeight: 84
                radius: Theme.settings.roundS
                color: Colors.colors.surface_container

                ClippingRectangle {
                    anchors.fill: parent
                    radius: parent.radius

                    Image {
                        anchors.fill: parent
                        source: MusicService.artUrl || ""
                        fillMode: Image.PreserveAspectCrop
                        visible: status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        text: "music_note"
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 32
                        color: Colors.colors.on_surface_variant
                        visible: MusicService.artUrl === ""
                    }
                }
            }

            // --- COLUMN 2: Info, Controls, and Progress ---
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 4

                // Metadata
                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true

                    Text {
                        text: MusicService.title || "No Media"
                        font.family: Theme.settings.fontFamily
                        font.pixelSize: 15
                        font.bold: true
                        color: Colors.colors.on_surface
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Text {
                        text: MusicService.artist || "Unknown Artist"
                        font.family: Theme.settings.fontFamily
                        font.pixelSize: 12
                        color: Colors.colors.on_surface_variant
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                // Playback Controls
                RowLayout {
                    spacing: 16

                    Text {
                        text: "skip_previous"
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 24
                        color: Colors.colors.on_surface
                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (MusicService.player)
                                MusicService.player.previous()
                        }
                    }

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 18
                        color: Colors.colors.primary

                        Text {
                            anchors.centerIn: parent
                            text: MusicService.isPlaying ? "pause_circle" : "play_circle"
                            font.family: Theme.settings.fontFamilyMaterial
                            font.pixelSize: 20
                            color: Colors.colors.on_primary
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: MusicService.toggle()
                        }
                    }

                    Text {
                        text: "skip_next"
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 24
                        color: Colors.colors.on_surface
                        MouseArea {
                            anchors.fill: parent
                            onClicked: if (MusicService.player)
                                MusicService.player.next()
                        }
                    }
                }

                Item {
                    Layout.fillHeight: true
                }

                // Progress Bar
                Item {
                    Layout.fillWidth: true
                    height: 4

                    Rectangle {
                        anchors.fill: parent
                        radius: 2
                        color: Colors.colors.on_surface
                        opacity: 0.1
                    }

                    Rectangle {
                        height: parent.height
                        radius: 2
                        color: Colors.colors.primary
                        width: parent.width * MusicService.progress

                        Behavior on width {
                            NumberAnimation {
                                duration: 1000
                                easing.type: Easing.Linear
                            }
                        }
                    }
                }
            }
        }
    }
}
