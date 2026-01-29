import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import "../../core"
import qs.modules.lockscreen.components

Rectangle {
    id: root
    required property LockContext context

    readonly property var colors: Colors.colors
    readonly property var tokens: Theme.values

    color: colors.surface

    FileView {
        id: wallpaperConfig
        path: Quickshell.env("HOME") + "/.config/quickshell/config/wallpaper.json"
        JsonAdapter {
            id: jsonStore
            property string currentPath: ""
        }
        onFileChanged: reload()
    }

    Image {
        id: wallpaperImage
        anchors.fill: parent
        source: jsonStore.currentPath ? "file://" + jsonStore.currentPath : ""
        fillMode: Image.PreserveAspectCrop
        visible: false
    }

    FastBlur {
        anchors.fill: wallpaperImage
        source: wallpaperImage
        radius: 50
        Rectangle {
            anchors.fill: parent
            color: colors.surface
            opacity: 0.5
        }
    }

    Timer {
        id: waitTimer
        interval: 600
        running: false
        repeat: false
        onTriggered: root.context.tryUnlock()
    }

    Connections {
        target: NetworkService
        function onIsConnectedChanged() {
            console.log("DEBUG - isConnected changed to: " + NetworkService.isConnected);
        }
        function onConnectedNameChanged() {
            console.log("DEBUG - SSID changed to: " + NetworkService.connectedName);
        }
    }

    ColumnLayout {
        anchors.right: parent.right
        anchors.rightMargin: 50

        anchors.verticalCenter: parent.verticalCenter
        Layout.fillHeight: false

        spacing: tokens.spacingM
        width: 400

        WeatherTimeRow {

            colors: root.colors
            tokens: root.tokens
            weatherData: WeatherService
        }

        UserBatteryRow {
            colors: root.colors
            tokens: root.tokens
        }

        PasswordRow {
            colors: root.colors
            tokens: root.tokens
            context: root.context
            onAccepted: waitTimer.start()
        }

        MusicRow {
            colors: root.colors
            tokens: root.tokens
        }

        StatusIndicatorsRow {
            colors: root.colors
            tokens: root.tokens
        }
    }
}
