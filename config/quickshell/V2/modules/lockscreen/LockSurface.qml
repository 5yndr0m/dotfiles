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
    readonly property var tokens: Theme.settings

    color: colors.surface

    FileView {
        id: wallpaperConfig
        path: Quickshell.env("HOME") + "/.config/quickshell/V2/config/wallpaper.json"
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

    StatusIndicatorsRow {
        id: statusRow
        anchors.top: parent.top
        anchors.topMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter
        // Explicit width is required when using anchors instead of Layouts
        width: 400

        colors: root.colors
        tokens: root.tokens
    }

    // --- CENTER STACK ---
    ColumnLayout {
        id: centerStack
        anchors.centerIn: parent
        spacing: 5 // Increased spacing to give the larger clock room to breathe
        width: 400

        WeatherTimeRow {
            colors: root.colors
            tokens: root.tokens
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
    }

    // --- BOTTOM CENTER ---
    MusicRow {
        id: musicRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter

        // Use standard properties, not Layout properties
        width: 400
        height: 80

        colors: root.colors
        tokens: root.tokens
    }
}
