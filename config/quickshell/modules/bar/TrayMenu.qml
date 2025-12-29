import QtQuick
import Quickshell
import Quickshell.DBusMenu
import qs.config

QsMenuAnchor {
    id: root
    property var menuHandle

    PopupWindow {
        id: popup
        visible: root.active

        Rectangle {
            implicitWidth: 200
            implicitHeight: itemsColumn.implicitHeight + 16

            color: ThemeAuto.surfaceContainer
            border.color: ThemeAuto.outlineVariant
            border.width: 1
            radius: 12

            Column {
                id: itemsColumn
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                Instantiator {
                    model: root.menuHandle ? root.menuHandle.items : []

                    delegate: Rectangle {
                        id: menuDelegate
                        width: itemsColumn.width
                        height: 36

                        color: itemMouse.containsMouse ? ThemeAuto.secondaryContainer : "transparent"
                        radius: 8

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            verticalAlignment: Text.AlignVCenter
                            text: modelData.label.replace(/&/g, "")

                            color: itemMouse.containsMouse ? ThemeAuto.on_SecondaryContainer : ThemeAuto.on_Surface

                            font {
                                family: Theme.fontFamily
                                pixelSize: Theme.fontSize
                                weight: itemMouse.containsMouse ? Font.Medium : Font.Normal
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }
                            }
                        }

                        MouseArea {
                            id: itemMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                modelData.trigger();
                                root.active = false;
                            }
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }
            }
        }
    }
}
