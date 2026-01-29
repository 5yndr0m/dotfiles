import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../core"
import qs.components

PopupWindow {
    id: root

    property var anchorWindow: null
    property var menuHandle: null
    property rect targetRect: Qt.rect(0, 0, 1, 1)

    signal requestClose

    property int menuWidth: 240

    property int cornerRadius: 24

    implicitWidth: menuWidth + (cornerRadius * 2)
    implicitHeight: Math.max(50, container.height)

    color: "transparent"
    visible: false

    anchor {
        window: root.anchorWindow
        rect.x: root.targetRect.x - ((implicitWidth - root.targetRect.width) / 2)
        rect.y: root.targetRect.y + root.targetRect.height + 6
    }

    HyprlandFocusGrab {
        active: root.visible
        windows: [root]
        onCleared: root.requestClose()
    }

    Item {
        anchors.fill: parent

        CornerShape {
            anchors.right: container.left
            anchors.top: container.top
            width: root.cornerRadius
            height: root.cornerRadius

            orientation: 1
            radius: root.cornerRadius
            color: Colors.colors.surface_container
        }

        CornerShape {
            anchors.left: container.right
            anchors.top: container.top
            width: root.cornerRadius
            height: root.cornerRadius

            orientation: 0
            radius: root.cornerRadius
            color: Colors.colors.surface_container
        }

        Rectangle {
            id: container
            z: 1

            width: root.menuWidth
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top

            property int safePadding: 10
            height: Math.max(20, stackView.height + (safePadding * 2))

            radius: root.cornerRadius
            color: Colors.colors.surface_container

            border.width: 0
            clip: true

            Rectangle {
                width: parent.width
                height: parent.radius
                anchors.top: parent.top
                color: parent.color
                z: 1
            }

            StackView {
                id: stackView
                z: 2
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: container.safePadding

                implicitHeight: currentItem ? currentItem.implicitHeight : 0

                pushEnter: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }
                pushExit: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }
                popEnter: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }
                popExit: Transition {
                    NumberAnimation {
                        duration: 0
                    }
                }

                initialItem: subMenuComp.createObject(stackView, {
                    handle: root.menuHandle
                })

                Connections {
                    target: root
                    function onMenuHandleChanged() {
                        stackView.clear();
                        if (root.menuHandle) {
                            stackView.push(subMenuComp.createObject(stackView, {
                                handle: root.menuHandle
                            }));
                        }
                    }
                }
            }
        }
    }

    Component {
        id: subMenuComp
        Column {
            property var handle
            property bool isSubMenu: false

            spacing: 4
            width: stackView.width
            visible: StackView.status === StackView.Active || StackView.status === StackView.Activating

            QsMenuOpener {
                id: opener
                menu: handle
            }

            Loader {
                active: isSubMenu
                visible: active
                width: parent.width
                height: active ? 32 : 0
                sourceComponent: Rectangle {
                    height: 32
                    width: parent.width
                    color: "transparent"
                    RowLayout {
                        anchors.fill: parent
                        spacing: 10
                        Text {
                            text: "←"
                            color: Colors.colors.on_surface
                        }
                        Text {
                            text: "Back"
                            color: Colors.colors.on_surface
                            font.bold: true
                        }
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: stackView.pop()
                    }
                }
            }

            Rectangle {
                visible: isSubMenu
                width: parent.width
                height: 1
                color: Colors.colors.outline_variant
            }

            Repeater {
                model: opener.children
                delegate: Loader {
                    width: parent.width
                    height: modelData.isSeparator ? 10 : 32
                    sourceComponent: modelData.isSeparator ? separatorItem : menuItem
                    Component {
                        id: separatorItem
                        Rectangle {
                            color: "transparent"
                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width
                                height: 1
                                color: Colors.colors.outline_variant
                            }
                        }
                    }
                    Component {
                        id: menuItem
                        Rectangle {
                            radius: 5
                            color: ms.containsMouse ? Colors.colors.secondary_container : "transparent"
                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 5
                                Image {
                                    visible: !!modelData.icon
                                    source: modelData.icon || ""
                                    Layout.preferredWidth: 16
                                    Layout.preferredHeight: 16
                                    fillMode: Image.PreserveAspectFit
                                }
                                Text {
                                    text: modelData.text
                                    color: Colors.colors.on_surface
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                                Text {
                                    visible: modelData.hasChildren
                                    text: "→"
                                    color: Colors.colors.on_surface
                                }
                            }
                            MouseArea {
                                id: ms
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    if (modelData.hasChildren) {
                                        stackView.push(subMenuComp.createObject(stackView, {
                                            handle: modelData,
                                            isSubMenu: true
                                        }));
                                    } else {
                                        modelData.triggered();
                                        root.requestClose();
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
