import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../core"

ColumnLayout {
    id: quickSettings
    spacing: Theme.settings.spacingM
    Layout.fillWidth: true

    // Signals for external use if needed
    signal wifiClicked
    signal bluetoothClicked

    // --- ROW 1: Large Buttons (Screenshots) ---
    RowLayout {
        spacing: Theme.settings.spacingM
        Layout.fillWidth: true

        QuickButtonLarge {
            icon: "crop_free"
            status: "Region"
            label: "Select"
            command: "hyprshot -m region"
            Layout.fillWidth: true
        }

        QuickButtonLarge {
            icon: "screenshot_monitor"
            status: "Output"
            label: "Screen"
            command: "hyprshot -m output"
            Layout.fillWidth: true
        }
    }

    // --- ROW 2: Standard Buttons (System Tools) ---
    RowLayout {
        spacing: Theme.settings.spacingM
        Layout.fillWidth: true

        QuickButton {
            icon: "monitoring"
            label: "Btop"
            command: "foot btop"
            Layout.fillWidth: true
        }

        QuickButton {
            icon: "refresh"
            label: "Reload"
            command: "sh -c 'pkill quickshell; quickshell'"
            isActive: true
            Layout.fillWidth: true
        }

        QuickButton {
            icon: "lock"
            label: "Lock"
            command: "hyprctl dispatch global quickshell:lockSession"
            isError: true
            Layout.fillWidth: true
        }
    }

    // --- COMPONENT: QuickButtonLarge ---
    component QuickButtonLarge: Rectangle {
        id: largeBtn
        property string icon: ""
        property string status: ""
        property string label: ""
        property string command: ""
        property bool isActive: false
        signal clicked

        implicitHeight: 64
        radius: Theme.settings.roundM
        color: largeBtn.isActive ? Colors.colors.primary : Colors.colors.surface_container_high

        Process {
            id: procLarge
            command: largeBtn.command.split(" ")
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            Text {
                text: largeBtn.icon
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: 24
                color: largeBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                Text {
                    text: largeBtn.status
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 10
                    font.bold: true
                    opacity: 0.8
                    color: largeBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant
                }

                Text {
                    text: largeBtn.label
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 12
                    font.bold: true
                    color: largeBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface
                    elide: Text.ElideRight
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (largeBtn.command !== "")
                    procLarge.running = true;
                largeBtn.clicked();
            }
        }
    }

    // --- COMPONENT: QuickButton ---
    component QuickButton: Rectangle {
        id: smallBtn
        property string icon: ""
        property string label: ""
        property string command: ""
        property bool isActive: false
        property bool isError: false
        signal clicked

        implicitHeight: 64
        radius: Theme.settings.roundM
        color: isError ? Colors.colors.error_container : (smallBtn.isActive ? Colors.colors.primary : Colors.colors.surface_container_high)

        Process {
            id: procSmall
            command: smallBtn.command.split(" ")
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 4
            Text {
                text: smallBtn.icon
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: 22
                color: isError ? Colors.colors.error : (smallBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface)
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: smallBtn.label
                font.family: Theme.settings.fontFamily
                font.pixelSize: 10
                font.bold: true
                color: isError ? Colors.colors.error : (smallBtn.isActive ? Colors.colors.on_primary : Colors.colors.on_surface_variant)
                Layout.alignment: Qt.AlignHCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (smallBtn.command !== "")
                    procSmall.running = true;
                smallBtn.clicked();
            }
        }
    }
}
