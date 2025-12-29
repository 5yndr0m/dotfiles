import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Services.Mpris
import qs.config

Rectangle {
    id: controlNowPlaying

    implicitWidth: parent.width - 10
    implicitHeight: 120

    radius: 16
    color: ThemeAuto.bgContainer
    border.width: 1
    border.color: ThemeAuto.outline

    property var player: null
    property real currentPosition: player ? player.position : 0

    // --- LOGIC ---
    function refreshPlayer() {
        let players = Mpris.players.values;
        if (players.length === 0) {
            player = null;
            return;
        }

        let playingPlayer = players.find(p => p && p.playbackState === "Playing");
        let newPlayer = playingPlayer || players[0];

        if (newPlayer !== player) {
            player = newPlayer;
        }
    }

    Timer {
        interval: 2000; running: true; repeat: true
        onTriggered: refreshPlayer()
    }

    Timer {
        interval: 1000
        running: player && (player.playbackState === "Playing" || player.playbackState === 1)
        repeat: true
        onTriggered: if (player) currentPosition = player.position
    }

    Component.onCompleted: refreshPlayer()

    Connections {
        target: Mpris.players
        function onValuesChanged() { refreshPlayer(); }
    }

    Connections {
        target: player
        function onPositionChanged() { controlNowPlaying.currentPosition = player.position; }
    }

    // --- BACKGROUND ART (BLURRED) ---
    Rectangle {
        id: backgroundContainer
        anchors.fill: parent
        radius: parent.radius
        clip: true

        Image {
            id: backgroundImage
            anchors.fill: parent
            source: player?.metadata?.["mpris:artUrl"] || ""
            fillMode: Image.PreserveAspectCrop
            visible: source.toString() !== ""

            layer.enabled: true
            layer.effect: MultiEffect {
                blur: 0.8
                brightness: -0.4
                saturation: 0.6
            }
        }

        Rectangle {
            anchors.fill: parent
            color: ThemeAuto.bgSurface
            opacity: 0.6
        }
    }

    // --- UI CONTENT ---
    RowLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 16

        // Album Art Thumbnail
        Rectangle {
            id: albumArt
            Layout.preferredWidth: 80
            Layout.preferredHeight: 80
            radius: 12
            color: ThemeAuto.bgContainer
            clip: true

            Image {
                anchors.fill: parent
                source: player?.metadata?.["mpris:artUrl"] || ""
                fillMode: Image.PreserveAspectCrop
            }

            Text {
                anchors.centerIn: parent
                text: "music_note"
                color: ThemeAuto.textMain
                font { family: "Material Symbols Rounded"; pixelSize: 32 }
                visible: !player?.metadata?.["mpris:artUrl"]
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            // Track title
            Text {
                text: player?.metadata?.["xesam:title"] || player?.title || "No media playing"
                color: ThemeAuto.textMain
                font { family: "Google Sans"; pixelSize: 16; weight: Font.Bold }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            // Artist & Time
            Text {
                text: {
                    if (!player) return "";
                    let artists = player.metadata?.["xesam:artist"]?.join(", ") || "Unknown Artist";

                    if (player.length > 0) {
                        let lengthMs = player.length > 10000000 ? player.length / 1000 : player.length;
                        let posMs = currentPosition > 10000000 ? currentPosition / 1000 : currentPosition;

                        let fmt = (ms) => `${Math.floor(ms/60000)}:${Math.floor((ms%60000)/1000).toString().padStart(2, '0')}`;
                        return artists + " • " + fmt(posMs) + " / " + fmt(lengthMs);
                    }
                    return artists;
                }
                color: ThemeAuto.outline
                font { family: "Google Sans"; pixelSize: 13 }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Item { Layout.preferredHeight: 4 } // Spacer

            // Progress Bar
            Rectangle {
                id: progressBar
                Layout.fillWidth: true
                height: 6
                radius: 3
                color: ThemeAuto.outline
                opacity: 0.3

                Rectangle {
                    width: (player && player.length > 0) ? parent.width * Math.min((currentPosition > 10000000 ? currentPosition/1000 : currentPosition) / (player.length > 10000000 ? player.length/1000 : player.length), 1) : 0
                    height: parent.height
                    radius: parent.radius
                    color: ThemeAuto.accent
                    Behavior on width { NumberAnimation { duration: 250 } }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: player?.canSeek || false
                    onClicked: mouse => {
                        let length = player.length;
                        let ratio = mouse.x / width;
                        player.position = length * ratio;
                    }
                }
            }

            // Controls
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 20

                MediaButton {
                    icon: "skip_previous"
                    enabled: player?.canGoPrevious || false
                    onClicked: player.previous()
                }

                MediaButton {
                    icon: (player?.playbackState === "Playing" || player?.playbackState === 1) ? "pause" : "play_arrow"
                    size: 40
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

    // Sub-component for buttons
    component MediaButton: Rectangle {
        property string icon: ""
        property int size: 32
        property bool enabled: true
        property bool isPrimary: false
        signal clicked

        Layout.preferredWidth: size
        Layout.preferredHeight: size
        radius: size / 2

        // Material 3 style: Primary buttons use accent, others are transparent/ghost
        color: isPrimary ? ThemeAuto.accent : (btnMouse.containsMouse ? ThemeAuto.outline : "transparent")
        opacity: enabled ? 1.0 : 0.4

        Text {
            anchors.centerIn: parent
            text: icon
            color: isPrimary ? ThemeAuto.bgSurface : ThemeAuto.textMain
            font { family: "Material Symbols Rounded"; pixelSize: size * 0.7 }
        }

        MouseArea {
            id: btnMouse
            anchors.fill: parent
            hoverEnabled: true
            onClicked: if (enabled) parent.clicked()
        }

        scale: btnMouse.pressed ? 0.9 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 200 } }
    }
}
