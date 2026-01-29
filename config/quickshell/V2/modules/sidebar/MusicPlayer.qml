import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import "../../core"

Rectangle {
    id: musicCard
    Layout.fillWidth: true
    implicitHeight: 110 // Increased slightly to give the progress bar breathing room
    radius: Theme.settings.roundM
    color: Colors.colors.surface_container_highest

    ClippingRectangle {
        anchors.fill: parent
        radius: parent.radius
        color: "transparent"

        // --- Background Album Art ---
        Image {
            anchors.fill: parent
            source: MusicService.artUrl || ""
            fillMode: Image.PreserveAspectCrop
            opacity: 0.15
            visible: MusicService.artUrl !== ""
        }

        // --- Flat Progress Bar Container ---
        Item {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            height: 4

            // Background Rail
            Rectangle {
                anchors.fill: parent
                radius: 2
                color: Colors.colors.on_surface
                opacity: 0.1
            }

            // Progress Fill
            Rectangle {
                id: progressFill
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

    RowLayout {
        // Anchored to top to keep content away from the bottom progress bar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 12
        spacing: 16

        // --- Album Art Thumbnail ---
        Rectangle {
            width: 64 // Sized down slightly for a tighter layout
            height: 64
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
                    text: "\ue405" // music_note
                    font.family: Theme.settings.fontFamilyMaterial
                    font.pixelSize: 28
                    color: Colors.colors.on_surface_variant
                    visible: MusicService.artUrl === ""
                }
            }
        }

        // --- Controls and Info ---
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: MusicService.title || "No Media"
                font.family: Theme.settings.fontFamily
                font.pixelSize: 14
                font.bold: true
                color: Colors.colors.on_surface
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: MusicService.artist || "Unknown"
                font.family: Theme.settings.fontFamily
                font.pixelSize: 11
                color: Colors.colors.on_surface_variant
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 12
                Layout.topMargin: 4

                // Skip Previous
                Text {
                    text: "\ue045"
                    font.family: Theme.settings.fontFamilyMaterial
                    font.pixelSize: 22
                    color: Colors.colors.on_surface
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (MusicService.player)
                            MusicService.player.previous()
                    }
                }

                // Play/Pause Circle
                Rectangle {
                    width: 32
                    height: 32
                    radius: 16
                    color: Colors.colors.primary

                    Text {
                        anchors.centerIn: parent
                        text: MusicService.isPlaying ? "\ue036" : "\ue037"
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 18
                        color: Colors.colors.on_primary
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: MusicService.toggle()
                    }
                }

                // Skip Next
                Text {
                    text: "\ue044"
                    font.family: Theme.settings.fontFamilyMaterial
                    font.pixelSize: 22
                    color: Colors.colors.on_surface
                    MouseArea {
                        anchors.fill: parent
                        onClicked: if (MusicService.player)
                            MusicService.player.next()
                    }
                }
            }
        }
    }
}
