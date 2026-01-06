import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import "../core"
import "."

Rectangle {
    id: root
    width: 360
    height: 130

    color: Colors.colors.surface_container
    radius: Theme.values.roundXL

    layer.enabled: true
    layer.effect: DropShadow {
        radius: 12
        samples: 17
        color: Qt.rgba(0, 0, 0, 0.3)
        verticalOffset: 4
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.values.paddingL
        anchors.bottomMargin: 24
        spacing: Theme.values.spacingL

        Rectangle {
            Layout.preferredWidth: 84
            Layout.preferredHeight: 84
            Layout.alignment: Qt.AlignVCenter
            color: "transparent"

            Item {
                anchors.fill: parent

                Image {
                    id: albumArt
                    anchors.fill: parent
                    source: MusicService.artUrl !== "" ? MusicService.artUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: source !== ""
                    smooth: true

                    layer.enabled: true
                    layer.effect: OpacityMask {
                        maskSource: Rectangle {
                            width: albumArt.width
                            height: albumArt.height
                            radius: Theme.values.roundM
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: "music_note"
                    font.family: Theme.values.fontFamilyMaterial
                    font.pixelSize: 40
                    color: Colors.colors.on_surface_variant
                    visible: !albumArt.visible
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MusicService.toggle()
                    onPressed: parent.opacity = 0.7
                    onReleased: parent.opacity = 1.0
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 2

            Text {
                Layout.fillWidth: true
                text: MusicService.title
                font {
                    family: Theme.values.fontFamily
                    pixelSize: 20
                    weight: Font.Bold
                }
                color: Colors.colors.on_surface
                elide: Text.ElideRight
            }

            Text {
                Layout.fillWidth: true
                text: MusicService.artist
                font {
                    family: Theme.values.fontFamily
                    pixelSize: 16
                    weight: Font.Medium
                }
                color: Colors.colors.on_surface_variant
                elide: Text.ElideRight
            }
        }
    }

    Rectangle {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: 18
            bottomMargin: 16
        }
        height: 8
        radius: 4
        color: Colors.colors.surface_container_highest

        Rectangle {
            height: parent.height
            width: parent.width * MusicService.progress
            radius: 4
            color: Colors.colors.primary

            Behavior on width {
                NumberAnimation {
                    duration: 1000
                }
            }
        }
    }
}
