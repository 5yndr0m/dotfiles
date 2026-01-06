import Quickshell
import QtQuick
import QtQuick.Layouts
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../core"

PanelWindow {
    id: root
    property var modelData
    signal notificationCenterRequested
    screen: modelData || null

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: Theme.values.barHeightS
    color: Colors.colors.surface_container

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.values.spacingM
        anchors.rightMargin: Theme.values.spacingM
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true
            Workspaces {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true

            Item {
                anchors.centerIn: parent
                width: clockLoader.implicitWidth + 20
                height: parent.height

                Clock {
                    id: clockLoader
                    anchors.centerIn: parent
                }

                HoverHandler {
                    id: clockHover
                    cursorShape: Qt.PointingHandCursor
                    onHoveredChanged: {
                        if (hovered) {
                            root.notificationCenterRequested();
                        }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            Layout.fillHeight: true

            RowLayout {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.values.spacingL

                Tray {}

                BatteryPill {}
            }
        }
    }
}
