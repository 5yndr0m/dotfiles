import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.modules.lockscreen

Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 80
    radius: 28
    color: colors.surface_container_low
    border.color: colors.outline_variant
    border.width: 1

    property var colors
    property var tokens
    property var context
    signal accepted

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 24
            color: colors.surface_container
            border.width: passwordBox.activeFocus ? 2 : 0
            border.color: colors.primary

            TextField {
                id: passwordBox
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                echoMode: TextInput.Password
                placeholderText: "Enter Password"
                placeholderTextColor: colors.on_surface_variant
                verticalAlignment: TextInput.AlignVCenter
                color: colors.on_surface
                font {
                    family: tokens.fontFamily
                    pixelSize: 14
                }
                background: Item {}
                onTextChanged: context.currentText = text
                onAccepted: parent.parent.parent.accepted()
                Component.onCompleted: forceActiveFocus()
            }
        }

        Rectangle {
            Layout.preferredWidth: 64
            Layout.fillHeight: true
            radius: 24
            color: context.unlockInProgress ? "#4caf50" : (context.showFailure ? colors.error : colors.primary)

            Text {
                anchors.centerIn: parent
                text: context.unlockInProgress ? "lock_open" : "lock"
                font {
                    family: tokens.fontFamilyMaterial
                    pixelSize: 24
                }
                color: colors.on_primary
            }
            MouseArea {
                anchors.fill: parent
                onClicked: parent.parent.parent.accepted()
            }
        }
    }
}
