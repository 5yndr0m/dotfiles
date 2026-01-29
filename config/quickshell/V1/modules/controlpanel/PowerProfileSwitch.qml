import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import "../../core"

Rectangle {
    id: powerControl
    implicitWidth: parent.width
    implicitHeight: 32
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
        spacing: Theme.values.spacingXS
        anchors.margins: 0

        Repeater {
            model: [
                {
                    id: "power-saver",
                    icon: "eco",
                    label: "Power"
                },
                {
                    id: "balanced",
                    icon: "balance",
                    label: "Balanced"
                },
                {
                    id: "performance",
                    icon: "rocket_launch",
                    label: "Performance"
                }
            ]

            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: activeProfile === modelData.id ? Colors.colors.primary : Colors.colors.surface_container_high
                radius: activeProfile === modelData.id ? Theme.values.roundM : Theme.values.roundS

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: modelData.icon
                        font.family: Theme.values.fontFamilyMaterial
                        font.pixelSize: 16
                        color: activeProfile === modelData.id ? Colors.colors.on_primary : Colors.colors.on_surface
                    }
                    Text {
                        text: modelData.label
                        font.family: Theme.values.fontFamily
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
