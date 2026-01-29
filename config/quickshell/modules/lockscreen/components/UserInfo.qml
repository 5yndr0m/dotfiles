import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../core"

ColumnLayout {
    id: root
    spacing: 12

    property var colors
    property var tokens

    // Avatar Container (Larger size)
    Rectangle {
        id: avatarContainer
        Layout.preferredWidth: 84
        Layout.preferredHeight: 84
        Layout.alignment: Qt.AlignHCenter
        radius: width / 2
        color: colors.surface_container_high
        clip: true

        Text {
            anchors.centerIn: parent
            text: SystemInfo.getUserInitials()
            color: colors.on_surface_variant
            font {
                family: tokens.fontFamily
                pixelSize: 28
                bold: true
            }
            visible: avatarImage.status !== Image.Ready
        }

        Image {
            id: avatarImage
            anchors.fill: parent
            source: SystemInfo.avatarPath
            fillMode: Image.PreserveAspectCrop
            visible: false
            asynchronous: true
        }

        OpacityMask {
            anchors.fill: parent
            source: avatarImage
            visible: avatarImage.status === Image.Ready
            maskSource: Rectangle {
                width: avatarContainer.width
                height: avatarContainer.height
                radius: avatarContainer.radius
            }
        }
    }

    // Username (Under the image)
    Text {
        Layout.alignment: Qt.AlignHCenter
        text: SystemInfo.username
        color: colors.on_surface
        font {
            family: tokens.fontFamily
            pixelSize: 22
            bold: true
        }
        elide: Text.ElideRight
        opacity: 0.9
    }
}
