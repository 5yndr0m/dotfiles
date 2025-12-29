import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Hyprland

import qs.services.notifs
import qs.config

Item {
    id: rootItem

    PanelWindow {
        id: root

        screen: {
            if (Hyprland.focusedMonitor) {
                for (let i = 0; i < Quickshell.screens.length; i++) {
                    let quickshellScreen = Quickshell.screens[i];
                    if (quickshellScreen.name === Hyprland.focusedMonitor.name) {
                        return quickshellScreen;
                    }
                }
            }
            return Quickshell.screens[0];
        }

        property ListModel notificationModel: Notifs.notificationModel

        color: "transparent"
        visible: Notifs.notificationModel.count > 0

        anchors.top: true
        // anchors.horizontalCenter: parent.horizontalCenter // Uncomment if you want center alignment

        implicitWidth: 320
        implicitHeight: notificationStack.implicitHeight + 100

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        Component.onCompleted: {
            Notifs.animateAndRemove.connect(function (notification, index) {
                if (notificationStack.children && notificationStack.children[index]) {
                    let delegate = notificationStack.children[index];
                    if (delegate && delegate.animateOut) {
                        delegate.animateOut();
                    }
                }
            });
        }

        Column {
            id: notificationStack
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.topMargin: 15
            spacing: 12
            width: 301

            Repeater {
                model: root.notificationModel

                delegate: Item {
                    id: delegateWrapper
                    width: 301
                    height: each.height + 10 // Extra space for shadow

                    function animateOut() { each.animateOut(); }

                    // --- Shadow for popups to make them float ---
                    DropShadow {
                        anchors.fill: each
                        horizontalOffset: 0; verticalOffset: 4
                        radius: 12; samples: 17
                        color: ThemeAuto.shadowColor
                        source: each
                    }

                    Rectangle {
                        id: each
                        width: 301
                        height: Math.max(80, contentColumn.implicitHeight + 24)
                        radius: 16
                        clip: true

                        // Use bgSurface for popups to distinguish from background panels
                        color: (model.urgency === NotificationUrgency.Critical)
                                ? ThemeAuto.bgContainer // Criticals get a slightly different tint
                                : ThemeAuto.bgSurface

                        border.color: (model.urgency === NotificationUrgency.Critical)
                                ? "#ffb4ab" // Red border for critical
                                : ThemeAuto.outline
                        border.width: 1

                        property real yOffset: -50
                        property real opacityValue: 0.0
                        property bool isRemoving: false

                        transform: Translate { y: each.yOffset }
                        opacity: opacityValue

                        Component.onCompleted: {
                            yOffset = 0;
                            opacityValue = 1.0;
                        }

                        function animateOut() {
                            isRemoving = true;
                            yOffset = -50;
                            opacityValue = 0.0;
                        }

                        Timer {
                            id: removalTimer
                            interval: 500
                            onTriggered: Notifs.forceRemoveNotification(model.rawNotification)
                        }

                        onIsRemovingChanged: if (isRemoving) removalTimer.start()

                        Behavior on yOffset { NumberAnimation { duration: 450; easing.type: Easing.OutQuint } }
                        Behavior on opacity { NumberAnimation { duration: 250 } }

                        Column {
                            id: contentColumn
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 8

                            RowLayout {
                                width: parent.width
                                spacing: 8
                                Text {
                                    text: (model.appName || model.desktopEntry) || "System"
                                    color: (model.urgency === NotificationUrgency.Critical) ? "#ffb4ab" : ThemeAuto.accent
                                    font { pixelSize: 12; bold: true; family: "Google Sans" }
                                }

                                Rectangle {
                                    width: 8; height: 8; radius: 4
                                    color: (model.urgency === NotificationUrgency.Critical) ? "#ffb4ab" : ThemeAuto.accent
                                    Layout.alignment: Qt.AlignVCenter
                                    visible: model.urgency !== NotificationUrgency.Low
                                }

                                Item { Layout.fillWidth: true }

                                Text {
                                    text: Notifs.formatTimestamp(model.timestamp)
                                    color: ThemeAuto.textSecondary
                                    font { pixelSize: 10; family: "Google Sans" }
                                }
                            }

                            Text {
                                text: model.summary || ""
                                font { pixelSize: 14; weight: Font.Bold; family: "Google Sans" }
                                color: ThemeAuto.textMain
                                width: parent.width - 24
                                elide: Text.ElideRight
                            }

                            Text {
                                text: model.body || ""
                                font { pixelSize: 12; family: "Google Sans" }
                                color: ThemeAuto.textSecondary
                                wrapMode: Text.Wrap
                                width: parent.width
                                maximumLineCount: 3
                                elide: Text.ElideRight
                            }
                        }

                        // Close Button
                        Text {
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.margins: 10
                            text: "close"
                            font { family: "Material Symbols Rounded"; pixelSize: 18 }
                            color: closeMouse.containsMouse ? ThemeAuto.accent : ThemeAuto.outline

                            MouseArea {
                                id: closeMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: each.animateOut()
                            }
                        }
                    }
                }
            }
        }
    }
}
