import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import qs.config

Rectangle {
    id: root
    required property LockContext context
    color: ThemeAuto.bgSurface

    // --- 1. BATTERY LOGIC ---
    property string batLevel: "0"
    property string batStatus: "Discharging"

    Process {
        id: batLevelProc
        command: ["cat", "/sys/class/power_supply/BAT0/capacity"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.batLevel = text.trim()
        }
    }

    Process {
        id: batStatusProc
        command: ["cat", "/sys/class/power_supply/BAT0/status"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.batStatus = text.trim()
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batLevelProc.running = true;
            batStatusProc.running = true;
        }
    }

    // --- 2. WALLPAPER LOGIC ---
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
        asynchronous: true
        visible: false
    }

    FastBlur {
        anchors.fill: wallpaperImage
        source: wallpaperImage
        radius: 50

        Rectangle {
            anchors.fill: parent
            color: ThemeAuto.bgSurface
            opacity: 0.5 // Darken the blurred wallpaper
        }
    }

    // --- 3. TOP RIGHT STATUS BAR ---
    RowLayout {
        anchors {
            top: parent.top
            right: parent.right
            margins: 32
        }
        spacing: 24

        RowLayout {
            spacing: 8
            Text {
                text: {
                    let lvl = parseInt(root.batLevel);
                    if (root.batStatus === "Charging") return "battery_charging_full";
                    if (lvl <= 10) return "battery_0_bar";
                    if (lvl <= 30) return "battery_2_bar";
                    if (lvl <= 60) return "battery_4_bar";
                    return "battery_full";
                }
                color: (parseInt(root.batLevel) <= 20 && root.batStatus !== "Charging") ? ThemeAuto.accent : ThemeAuto.textMain
                font { family: "Material Symbols Rounded"; pixelSize: 24 }
            }
            Text {
                text: root.batLevel + "%"
                color: ThemeAuto.textMain
                font { family: "Google Sans"; pixelSize: 14; weight: Font.Medium }
            }
        }

        // Power Button
        Rectangle {
            id: powerButton
            width: 48; height: 48; radius: 24
            color: powerMouse.containsMouse ? ThemeAuto.accent : ThemeAuto.bgContainer

            Behavior on color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                text: "power_settings_new"
                color: powerMouse.containsMouse ? ThemeAuto.bgSurface : ThemeAuto.textMain
                font { family: "Material Symbols Rounded"; pixelSize: 24 }
            }

            MouseArea {
                id: powerMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Quickshell.execute(["systemctl", "poweroff"])
            }

            scale: powerMouse.pressed ? 0.92 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
    }

    // --- 4. NOW PLAYING MODULE ---
    LockNowPlaying {
        id: nowPlaying
        anchors {
            bottom: parent.bottom
            left: parent.left
            margins: 32
        }
        width: 400
        player: Mpris.defaultPlayer
        visible: player !== null && player.playbackState !== MprisPlaybackState.Stopped
    }

    property date currentTime: new Date()
    Timer {
        interval: 1000; running: true; repeat: true
        onTriggered: root.currentTime = new Date()
    }

    // --- 5. CLOCK & DATE (TOP LEFT) ---
    ColumnLayout {
        anchors { left: parent.left; top: parent.top; margins: 60 }
        spacing: 0

        RowLayout {
            spacing: 15
            Text {
                id: mainTime
                text: Qt.formatDateTime(root.currentTime, "HH:mm")
                color: ThemeAuto.textMain
                font { family: "Google Sans"; pixelSize: 140; weight: Font.Bold; letterSpacing: -5 }
            }

            Text {
                text: Qt.formatDateTime(root.currentTime, "ss")
                color: ThemeAuto.outline
                Layout.alignment: Qt.AlignVCenter
                font { family: "Google Sans"; pixelSize: 40; weight: Font.Medium }
            }
        }

        RowLayout {
            Layout.preferredWidth: mainTime.implicitWidth
            Text {
                text: Qt.formatDateTime(root.currentTime, "dddd, d MMMM")
                color: ThemeAuto.textMain
                font { family: "Google Sans"; pixelSize: 32; weight: Font.DemiBold }
                Layout.alignment: Qt.AlignLeft
            }
            Item { Layout.fillWidth: true }
            Text {
                text: Qt.formatDateTime(root.currentTime, "yyyy")
                color: ThemeAuto.outline
                font { family: "Google Sans"; pixelSize: 24; weight: Font.Light }
                Layout.alignment: Qt.AlignRight
            }
        }
    }

    // --- 6. AUTH UI ---
    ColumnLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 50
        spacing: 15
        width: 280

        Text {
            text: Quickshell.env("USER").toUpperCase()
            color: ThemeAuto.accent
            font { family: "Google Sans"; pixelSize: 14; letterSpacing: 3; weight: Font.Bold }
            Layout.alignment: Qt.AlignHCenter
            opacity: 0.8
        }

        TextField {
            id: passwordBox
            focus: true
            echoMode: TextInput.Password
            placeholderText: "Password"
            enabled: !root.context.unlockInProgress
            horizontalAlignment: TextInput.AlignHCenter
            color: ThemeAuto.textMain
            font { family: "Google Sans"; pixelSize: 16 }
            Layout.preferredWidth: 260
            Layout.preferredHeight: 46

            onTextChanged: root.context.currentText = text
            onAccepted: root.context.tryUnlock()

            background: Rectangle {
                color: ThemeAuto.bgContainer
                radius: 12
                opacity: 0.9
                border.width: passwordBox.activeFocus ? 2 : 1
                border.color: passwordBox.activeFocus ? ThemeAuto.accent : ThemeAuto.outline
            }

            Timer {
                interval: 100; running: true; repeat: false
                onTriggered: passwordBox.forceActiveFocus()
            }
        }

        Button {
            id: unlockButton
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 50; Layout.preferredHeight: 50
            flat: true
            onClicked: root.context.tryUnlock()

            background: Rectangle {
                radius: 25
                color: unlockButton.hovered ? ThemeAuto.accent : "transparent"
                border.color: ThemeAuto.outline
                border.width: 1
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            contentItem: Text {
                text: "lock_open"
                font { family: "Material Symbols Rounded"; pixelSize: 24 }
                color: unlockButton.hovered ? ThemeAuto.bgSurface : ThemeAuto.accent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }

        Text {
            text: "Incorrect Password"
            color: ThemeAuto.accent // Using accent for visibility
            visible: root.context.showFailure
            font { family: "Google Sans"; pixelSize: 12; weight: Font.Medium }
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
