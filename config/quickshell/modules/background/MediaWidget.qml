import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../core"

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 84

    // --- Visibility Logic ---
    visible: MusicService.player !== null
    opacity: visible ? 1 : 0
    Behavior on opacity {
        NumberAnimation {
            duration: 300
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colors.colors.surface_container
        radius: Theme.settings.roundXL
        clip: true

        Rectangle {
            id: musicProgressFill
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 4
            height: parent.height - 8
            radius: Theme.settings.roundXL - 4

            width: Math.max(0, (parent.width - 8) * MusicService.progress)

            color: Colors.colors.primary
            opacity: 0.15

            Behavior on width {
                NumberAnimation {
                    duration: 1000
                    easing.type: Easing.Linear
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.settings.paddingL
            anchors.rightMargin: Theme.settings.paddingL
            spacing: Theme.settings.spacingM

            // Album Art
            ClippingWrapperRectangle {
                Layout.preferredWidth: 56
                Layout.preferredHeight: 56
                Layout.alignment: Qt.AlignVCenter
                radius: Theme.settings.roundL
                color: Colors.colors.surface_container_high

                Image {
                    anchors.fill: parent
                    source: MusicService.artUrl || ""
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            // Metadata Column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: MusicService.title
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    color: Colors.colors.on_surface
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    text: MusicService.artist
                    font.family: Theme.settings.fontFamily
                    font.pixelSize: 11
                    color: Colors.colors.on_surface_variant
                    opacity: 0.8
                    elide: Text.ElideRight
                }
            }

            // Play/Pause Button (Circular)
            Rectangle {
                Layout.preferredWidth: 44
                Layout.preferredHeight: 44
                radius: 22
                color: Colors.colors.surface_container_high

                Text {
                    anchors.centerIn: parent
                    text: MusicService.isPlaying ? "\ue036" : "\ue037"
                    font.family: Theme.settings.fontFamilyMaterial
                    font.pixelSize: 24
                    color: Colors.colors.primary
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: MusicService.toggle()
                }
            }
        }
    }
}
