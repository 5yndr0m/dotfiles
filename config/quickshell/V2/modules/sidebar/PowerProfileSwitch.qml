import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../core"

Rectangle {
    id: powerControl
    Layout.fillWidth: true
    implicitHeight: 40 // Increased slightly for better touch/click targets
    color: "transparent"

    property string activeProfile: "balanced"

    Process {
        id: setPowerProc
    }

    Process {
        command: ["powerprofilesctl", "get"]
        running: true
        stdout: SplitParser {
            onRead: data => activeProfile = data.trim()
        }
    }

    function changeProfile(profile) {
        activeProfile = profile;
        setPowerProc.command = ["powerprofilesctl", "set", profile];
        setPowerProc.running = true;
    }

    RowLayout {
        anchors.fill: parent
        spacing: Theme.settings.spacingS

        Repeater {
            model: [
                {
                    id: "power-saver",
                    icon: "eco",
                    label: "Saver"
                } // eco/leaf
                ,
                {
                    id: "balanced",
                    icon: "balance",
                    label: "Balanced"
                } // scale/balance
                ,
                {
                    id: "performance",
                    icon: "rocket_launch",
                    label: "Performance"
                }   // rocket
            ]

            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Corrected to use Theme.settings and Colors.colors
                color: activeProfile === modelData.id ? Colors.colors.primary : Colors.colors.surface_container_high
                radius: Theme.settings.roundM

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: modelData.icon
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: 16
                        color: activeProfile === modelData.id ? Colors.colors.on_primary : Colors.colors.on_surface
                    }
                    Text {
                        text: modelData.label
                        font.family: Theme.settings.fontFamily
                        font.pixelSize: 10
                        font.bold: true
                        color: activeProfile === modelData.id ? Colors.colors.on_primary : Colors.colors.on_surface
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: changeProfile(modelData.id)
                }
            }
        }
    }
}
