import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../core"

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 80
    radius: 28
    color: colors.surface_container_low
    border.color: colors.outline_variant
    border.width: 1
    clip: true

    property var colors
    property var tokens

    Rectangle {
        id: musicProgressFill
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 4
        height: parent.height - 8
        radius: 24
        width: Math.max(0, (parent.width - 8) * MusicService.progress)
        color: colors.primary
        opacity: 0.15
        Behavior on width {
            NumberAnimation {
                duration: 1000
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: tokens.spacingM

        Item {
            id: albumArtContainer
            Layout.preferredWidth: 56
            Layout.preferredHeight: 56

            Rectangle {
                anchors.fill: parent
                radius: 16
                color: colors.surface_container_high
                visible: musicImage.status !== Image.Ready
                Text {
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: tokens.fontFamilyMaterial
                    font.pixelSize: 24
                    color: colors.primary
                }
            }

            Image {
                id: musicImage
                anchors.fill: parent
                source: (MusicService.artUrl && MusicService.artUrl !== "") ? MusicService.artUrl : ""
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            OpacityMask {
                anchors.fill: parent
                source: musicImage
                maskSource: Rectangle {
                    width: 56
                    height: 56
                    radius: 16
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Layout.alignment: Qt.AlignVCenter

            Text {
                Layout.fillWidth: true
                text: MusicService.title || "Nothing Playing"
                color: colors.on_surface
                font {
                    family: tokens.fontFamily
                    pixelSize: 14
                    bold: true
                }
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: MusicService.artist || "Unknown Artist"
                color: colors.on_surface_variant
                font {
                    family: tokens.fontFamily
                    pixelSize: 11
                }
                elide: Text.ElideRight
            }
        }

        Rectangle {
            Layout.preferredWidth: 48
            Layout.preferredHeight: 48
            radius: 24
            color: colors.surface_container_high
            Text {
                anchors.centerIn: parent
                text: MusicService.isPlaying ? "pause" : "play_arrow"
                font {
                    family: tokens.fontFamilyMaterial
                    pixelSize: 24
                }
                color: colors.primary
            }
            MouseArea {
                anchors.fill: parent
                onClicked: MusicService.toggle()
            }
        }
    }
}
