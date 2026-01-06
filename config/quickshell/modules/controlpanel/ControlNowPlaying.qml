import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import "../../core"
import qs.components

Rectangle {
    id: controlNowPlaying
    implicitWidth: parent.width - 10
    implicitHeight: 120
    color: "transparent"

    property var player: null
    property real currentPosition: player ? player.position : 0

    function refreshPlayer() {
        let players = Mpris.players.values;
        if (players.length === 0) {
            player = null;
            return;
        }
        let playingPlayer = players.find(p => p && p.playbackState === "Playing");
        player = playingPlayer || players[0];
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: refreshPlayer()
    }
    Timer {
        interval: 1000
        running: player && (player.playbackState === "Playing" || player.playbackState === 1)
        repeat: true
        onTriggered: if (player)
            currentPosition = player.position
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.values.paddingL
        spacing: Theme.values.paddingL

        Rectangle {
            id: albumArtContainer
            Layout.preferredWidth: 72
            Layout.preferredHeight: 72
            radius: Theme.values.roundM
            color: Colors.colors.surface_container_high || "transparent"

            Image {
                id: albumArtImage
                anchors.fill: parent
                source: player?.metadata?.["mpris:artUrl"] || ""
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: OpacityMask {
                    maskSource: Rectangle {
                        width: 72
                        height: 72
                        radius: Theme.values.roundM
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: player?.metadata?.["xesam:title"] || "No media playing"
                color: Colors.colors.on_surface || "transparent"
                font {
                    family: Theme.values.fontFamily
                    pixelSize: Theme.values.fontSize
                    bold: true
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: player?.metadata?.["xesam:artist"]?.join(", ") || "Unknown Artist"
                color: Colors.colors.on_surface_variant || "transparent"
                font {
                    family: Theme.values.fontFamily
                    pixelSize: Theme.values.fontSize - 2
                }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            M3SliderPlayback {
                Layout.fillWidth: true
                Layout.topMargin: 4
                value: (player && player.length > 0) ? (currentPosition / player.length) : 0
                accentColor: Colors.colors.primary || "transparent"

                onMoved: val => {
                    if (player && player.canSeek) {
                        player.position = player.length * val;
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Theme.values.spacingXL

                MediaButton {
                    icon: "skip_previous"
                    enabled: player?.canGoPrevious || false
                    onClicked: player.previous()
                }

                MediaButton {
                    icon: (player?.playbackState === "Playing" || player?.playbackState === 1) ? "pause" : "play_arrow"
                    size: 42
                    isPrimary: true
                    onClicked: (player?.playbackState === "Playing" || player?.playbackState === 1) ? player.pause() : player.play()
                }

                MediaButton {
                    icon: "skip_next"
                    enabled: player?.canGoNext || false
                    onClicked: player.next()
                }
            }
        }
    }
}
