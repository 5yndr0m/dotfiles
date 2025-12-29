import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.DBusMenu
import QtQuick.Controls
import qs.config

PanelWindow {
    id: root

    property var modelData
    property var controlPanel

    screen: modelData || null

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 32 // Slightly taller for better breathing room

    color: ThemeAuto.bgSurface

    // --- Bottom Border/Outline ---
    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: ThemeAuto.outline
        opacity: 0.3
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        // --- Left: Workspace Indicators ---
        Row {
            spacing: 8
            Layout.alignment: Qt.AlignVCenter

            Repeater {
                model: Hyprland.workspaces.values.length < 5 ? 5 : Hyprland.workspaces.values

                Rectangle {
                    id: indicator
                    property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                    property bool isActive: Hyprland.focusedWorkspace?.id === (index + 1)
                    property bool isHovered: mouseArea2.containsMouse

                    height: 10
                    implicitWidth: isActive ? 32 : (isHovered ? 20 : (ws ? 14 : 10))
                    radius: 5

                    color: {
                        if (isActive) return ThemeAuto.accent;
                        if (ws) return ThemeAuto.accent;
                        return ThemeAuto.outline;
                    }

                    opacity: isActive ? 1.0 : (ws ? 0.6 : 0.3)

                    Behavior on implicitWidth {
                        NumberAnimation { duration: 400; easing.type: Easing.OutExpo }
                    }

                    Behavior on color { ColorAnimation { duration: 200 } }

                    MouseArea {
                        id: mouseArea2
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hyprland.dispatch("workspace " + (index + 1))
                    }
                }
            }
        }

        Item { Layout.fillWidth: true }

        // --- Center: Active Window Title ---
        Text {
            text: Hyprland.activeToplevel?.title || "Desktop"
            color: Hyprland.activeToplevel ? ThemeAuto.textMain : ThemeAuto.textSecondary
            font {
                family: "Google Sans"
                pixelSize: 13
                weight: Hyprland.activeToplevel ? Font.DemiBold : Font.Normal
            }
            elide: Text.ElideRight
            Layout.maximumWidth: 400

            Behavior on color { ColorAnimation { duration: 300 } }
        }

        Item { Layout.fillWidth: true }

        // --- Right: Tray, Clock & Settings ---
        RowLayout {
            spacing: 16
            Layout.alignment: Qt.AlignVCenter

            // System Tray
            Row {
                id: trayRow
                spacing: 10
                Repeater {
                    model: SystemTray.items
                    delegate: MouseArea {
                        id: trayItemRoot
                        width: 20; height: 20
                        hoverEnabled: true
                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        QsMenuAnchor {
                            id: trayMenuAnchor
                            menu: modelData.menu
                            anchor {
                                window: root
                                rect: {
                                    let coords = trayItemRoot.mapToItem(root.contentItem, 0, 0);
                                    return Qt.rect(coords.x, 0, trayItemRoot.width, root.height);
                                }
                                gravity: Edges.Bottom
                            }
                        }

                        onClicked: mouse => {
                            if (mouse.button === Qt.RightButton && modelData.hasMenu) {
                                trayMenuAnchor.open();
                            } else {
                                modelData.activate();
                            }
                        }

                        IconImage {
                            anchors.fill: parent
                            source: modelData.icon
                            opacity: trayItemRoot.containsMouse ? 1.0 : 0.8
                        }
                    }
                }
            }

            // Clock
            Text {
                id: clock
                color: ThemeAuto.textMain
                font { family: "Google Sans"; pixelSize: 13; weight: Font.Bold }
                text: Qt.formatDateTime(new Date(), "ddd, MMM dd  HH:mm")

                Timer {
                    interval: 1000; running: true; repeat: true
                    onTriggered: clock.text = Qt.formatDateTime(new Date(), "ddd, MMM dd  HH:mm")
                }
            }

            // Control/Settings Button
            Rectangle {
                id: controlButton
                width: 32; height: 24; radius: 6
                color: mouseArea.containsMouse ? ThemeAuto.accent : "transparent"
                border.color: ThemeAuto.accent
                border.width: 1

                opacity: mouseArea.containsMouse ? 1.0 : 0.7

                Text {
                    anchors.centerIn: parent
                    text: "settings"
                    color: mouseArea.containsMouse ? ThemeAuto.bgSurface : ThemeAuto.accent
                    font.family: "Material Symbols Rounded"
                    font.pixelSize: 16
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: if (controlPanel) controlPanel.toggle();
                }

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
