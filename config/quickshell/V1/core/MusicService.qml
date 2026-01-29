pragma Singleton
import QtQuick
import Quickshell.Services.Mpris

Item {
    id: musicService

    property var player: null

    readonly property string title: player && player.metadata["xesam:title"] ? player.metadata["xesam:title"] : "No Media Playing"

    readonly property string artist: {
        if (!player || !player.metadata["xesam:artist"])
            return "Unknown Artist";

        let a = player.metadata["xesam:artist"];

        if (Array.isArray(a)) {
            return a.join(", ");
        }

        return a.toString();
    }

    readonly property string artUrl: player && player.metadata["mpris:artUrl"] ? player.metadata["mpris:artUrl"] : ""

    property real progress: 0
    property bool isPlaying: player ? (player.playbackState === "Playing" || player.playbackState === 1) : false

    function refreshPlayer() {
        let players = Mpris.players.values;
        if (players.length === 0) {
            player = null;
            return;
        }
        let playingPlayer = players.find(p => p && (p.playbackState === "Playing" || p.playbackState === 1));
        player = playingPlayer || players[0];
    }

    property Timer discoveryTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: musicService.refreshPlayer()
    }

    property Timer progressTimer: Timer {
        interval: 1000
        running: musicService.isPlaying
        repeat: true
        onTriggered: {
            if (player && player.length > 0)
                musicService.progress = player.position / player.length;
        }
    }

    function toggle() {
        if (player)
            isPlaying ? player.pause() : player.play();
    }
}
