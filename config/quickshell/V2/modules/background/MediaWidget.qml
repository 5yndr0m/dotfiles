import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import "../../core"

Item {
    id: root
    implicitWidth: 340
    implicitHeight: 84

    Rectangle {
        anchors.fill: parent
        color: Colors.colors.surface_container
        radius: Theme.settings.roundXL
        // clip: true // Optional: ensures child content doesn't bleed out

        RowLayout {
            anchors.fill: parent
            // Padding around the inner content
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
                    source: MusicService.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true

                    MouseArea {
                        anchors.fill: parent
                        onClicked: MusicService.toggle()
                    }
                }
            }

            // Metadata & Progress Column
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 4

                Column {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        width: parent.width
                        text: MusicService.title
                        font.family: Theme.settings.fontFamily
                        font.pixelSize: Theme.settings.fontSize + 1
                        font.weight: Font.Bold
                        color: Colors.colors.on_surface
                        elide: Text.ElideRight
                    }

                    Text {
                        width: parent.width
                        text: MusicService.artist
                        font.family: Theme.settings.fontFamily
                        font.pixelSize: Theme.settings.fontSize - 1
                        color: Colors.colors.on_surface_variant
                        opacity: 0.7
                        elide: Text.ElideRight
                    }
                }

                // Progress Bar
                Rectangle {
                    id: track
                    Layout.fillWidth: true
                    Layout.preferredHeight: 4
                    Layout.topMargin: 4
                    color: Colors.colors.surface_variant
                    radius: Theme.settings.roundFull

                    Rectangle {
                        id: fill
                        height: parent.height
                        width: parent.width * MusicService.progress
                        color: Colors.colors.primary
                        radius: Theme.settings.roundFull

                        Behavior on width {
                            NumberAnimation {
                                duration: 500
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
