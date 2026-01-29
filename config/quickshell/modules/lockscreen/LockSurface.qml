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

    BatteryPill {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 25
        anchors.leftMargin: 25
        colors: root.colors
        tokens: root.tokens
    }

    StatusIndicatorsRow {
        id: statusRow
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 25
        anchors.rightMargin: 25

        colors: root.colors
        tokens: root.tokens
    }

    ColumnLayout {
        id: centerStack
        anchors.centerIn: parent
        spacing: 20
        width: 400

        WeatherTimeRow {
            colors: root.colors
            tokens: root.tokens
        }

        UserInfo {
            Layout.alignment: Qt.AlignHCenter
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

    MusicRow {
        id: musicRow
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        anchors.horizontalCenter: parent.horizontalCenter

        width: 400
        height: 80

        colors: root.colors
        tokens: root.tokens
    }
}
