import QtQuick
import QtQuick.Layouts
import "../../core"

ColumnLayout {
    id: notificationCenterRoot
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 12

    // --- HEADER ---
    RowLayout {
        Layout.fillWidth: true

        Text {
            text: "NOTIFICATIONS"
            color: Colors.colors.primary
            font {
                family: Theme.settings.fontFamily
                pixelSize: 10
                bold: true
            }
        }

        Item {
            Layout.fillWidth: true
        }

        // DND Toggle
        MouseArea {
            width: 24
            height: 24
            cursorShape: Qt.PointingHandCursor
            onClicked: NotificationService.dndActive = !NotificationService.dndActive

            Text {
                anchors.centerIn: parent
                text: NotificationService.dndActive ? "\ue612" : "\ue7f4"
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: 16
                color: NotificationService.dndActive ? Colors.colors.error : Colors.colors.on_surface_variant
            }
        }

        // Clear All
        MouseArea {
            width: 24
            height: 24
            cursorShape: Qt.PointingHandCursor
            onClicked: NotificationService.clearHistory()

            Text {
                anchors.centerIn: parent
                text: "\ue872"
                font.family: Theme.settings.fontFamilyMaterial
                font.pixelSize: 16
                color: Colors.colors.on_surface_variant
            }
        }
    }

    // --- NOTIFICATION LIST ---
    ListView {
        id: notificationList
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: NotificationService.historyModel
        clip: true
        spacing: 8

        // Empty State Placeholder
        Text {
            visible: notificationList.count === 0
            anchors.centerIn: parent
            text: "No history"
            color: Colors.colors.on_surface_variant
            font {
                family: Theme.settings.fontFamily
                pixelSize: 11
                italic: true
            }
        }

        delegate: Rectangle {
            width: notificationList.width
            implicitHeight: notificationColumn.implicitHeight + 16
            color: Colors.colors.surface_container_low
            radius: 8
            border.color: Colors.colors.outline_variant
            border.width: 1

            ColumnLayout {
                id: notificationColumn
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: 8
                }
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        text: (model.appName || "System").toUpperCase()
                        color: Colors.colors.secondary
                        font {
                            family: Theme.settings.fontFamily
                            pixelSize: 9
                            bold: true
                        }
                        elide: Qt.ElideRight // Using Qt namespace to fix warnings
                        Layout.fillWidth: true
                    }
                    Text {
                        text: NotificationService.formatTimestamp(model.timestamp)
                        color: Colors.colors.on_surface_variant
                        font {
                            family: Theme.settings.fontFamily
                            pixelSize: 9
                        }
                    }
                    MouseArea {
                        width: 12
                        height: 12
                        onClicked: NotificationService.removeHistoryAt(index)
                        Text {
                            anchors.centerIn: parent
                            text: "\ue5cd"
                            font.family: Theme.settings.fontFamilyMaterial
                            font.pixelSize: 12
                            color: Colors.colors.on_surface_variant
                        }
                    }
                }

                Text {
                    text: model.summary || ""
                    color: Colors.colors.on_surface
                    font {
                        family: Theme.settings.fontFamily
                        pixelSize: 11
                        bold: true
                    }
                    elide: Qt.ElideRight // Using Qt namespace to fix warnings
                    Layout.fillWidth: true
                }

                Text {
                    text: model.body || ""
                    visible: text !== ""
                    color: Colors.colors.on_surface_variant
                    font {
                        family: Theme.settings.fontFamily
                        pixelSize: 10
                    }
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    elide: Qt.ElideRight // ElideRight is more consistent than ElideBottom in some QML versions
                    Layout.fillWidth: true
                }
            }
        }
    }
}
