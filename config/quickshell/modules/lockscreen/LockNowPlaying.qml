import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell.Services.Mpris
import qs.config

Rectangle {
    id: controlNowPlaying

    implicitWidth: parent.width - 10
    implicitHeight: 100

    border.width: 8
    border.color: ThemeAuto.outline
    radius: 64
    color: ThemeAuto.bgContainer

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
    Component.onCompleted: refreshPlayer()

    // Background Image/Blur
    Item {
        id: backgroundClipContainer
        anchors.fill: parent

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: player?.metadata?.["mpris:artUrl"] || ""
            fillMode: Image.PreserveAspectCrop
            visible: false
            smooth: true
        }

        GaussianBlur {
            id: blurredBackground
            anchors.fill: backgroundImage
            source: backgroundImage
            radius: 16
            samples: 8
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: blurredBackground
            maskSource: Rectangle {
                width: controlNowPlaying.width
                height: controlNowPlaying.height
                radius: controlNowPlaying.radius
            }
        }

        Rectangle {
            anchors.fill: parent
            color: ThemeAuto.bgContainer
            opacity: 0.7
            radius: controlNowPlaying.radius
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Album Art
        Rectangle {
            id: albumArt
            Layout.preferredWidth: 64
            Layout.preferredHeight: 64
            radius: 32
            color: ThemeAuto.bgSurface

            Image {
                id: thumbImage
                anchors.fill: parent
                anchors.margins: 2
                source: player?.metadata?.["mpris:artUrl"] || ""
                fillMode: Image.PreserveAspectCrop
                visible: false
            }

            OpacityMask {
                anchors.fill: thumbImage
                source: thumbImage
                maskSource: Rectangle {
                    width: thumbImage.width
                    height: thumbImage.height
                    radius: 32
                }
            }

            Text {
                anchors.centerIn: parent
                text: "music_note"
                color: ThemeAuto.textSecondary
                font {
                    family: "Material Symbols Rounded"
                    pixelSize: 28
                }
                visible: thumbImage.status !== Image.Ready
            }

            // Interaction: Tap album art to Play/Pause
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (player) {
                        if (player.playbackState === "Playing" || player.playbackState === 1)
                            player.pause();
                        else
                            player.play();
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            // Track Info
            Column {
                Layout.fillWidth: true
                spacing: 0
                Text {
                    width: parent.width
                    text: player?.metadata?.["xesam:title"] || "No Media"
                    color: ThemeAuto.textMain
                    font {
                        family: Theme.fontFamily
                        pixelSize: 14
                        bold: true
                    }
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: (player?.metadata?.["xesam:artist"] || ["Unknown Artist"]).join(", ")
                    color: ThemeAuto.textSecondary
                    font {
                        family: Theme.fontFamily
                        pixelSize: 12
                    }
                    elide: Text.ElideRight
                }
            }

            // Progress Bar
            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: 8
                height: 4
                radius: 2
                color: ThemeAuto.outline

                Rectangle {
                    width: parent.width * Math.min((currentPosition / (player?.length || 1)), 1)
                    height: parent.height
                    radius: parent.radius
                    color: ThemeAuto.accent
                    Behavior on width {
                        NumberAnimation {
                            duration: 500
                            easing.type: Easing.OutExpo
                        }
                    }
                }
            }
        }
    }
}
