import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import "../../core"

PanelWindow {
    id: root

    screen: {
        if (Hyprland.focusedMonitor) {
            let found = Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor.name);
            if (found)
                return found;
        }
        return Quickshell.screens[0];
    }

    color: "transparent"
    visible: NotificationService.notificationModel.count > 0

    anchors.top: true
    anchors.right: true
    margins.top: Theme.settings.spacingL + 20
    margins.right: Theme.settings.spacingXS

    implicitWidth: 360
    implicitHeight: 600

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    ListView {
        id: notificationList
        anchors.fill: parent
        model: NotificationService.notificationModel
        spacing: 12
        interactive: false
        clip: true

        add: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: 400
            }
            NumberAnimation {
                property: "x"
                from: 150
                to: 0
                duration: 400
                easing.type: Easing.OutExpo
            }
        }

        remove: Transition {
            ParallelAnimation {
                NumberAnimation {
                    property: "opacity"
                    to: 0
                    duration: 200
                }
                NumberAnimation {
                    property: "x"
                    to: 200
                    duration: 300
                    easing.type: Easing.InBack
                }
            }
        }

        displaced: Transition {
            NumberAnimation {
                properties: "y"
                duration: 400
                easing.type: Easing.OutBack
            }
        }

        delegate: Item {
            id: wrapper
            width: 350
            height: content.height + 12

            Connections {
                target: NotificationService
                function onAnimateAndRemove(notification, index) {
                    if (model.rawNotification === notification) {
                        wrapper.animateOut();
                    }
                }
            }

            function animateOut() {
                exitLocal.start();
            }

            SequentialAnimation {
                id: exitLocal
                ParallelAnimation {
                    NumberAnimation {
                        target: content
                        property: "x"
                        to: 400
                        duration: 300
                        easing.type: Easing.InExpo
                    }
                    NumberAnimation {
                        target: wrapper
                        property: "opacity"
                        to: 0
                        duration: 200
                    }
                }
                ScriptAction {
                    script: NotificationService.forceRemoveNotification(model.rawNotification)
                }
            }

            Rectangle {
                id: content
                width: wrapper.width - 10
                height: mainRow.implicitHeight + 24
                radius: Theme.settings.roundM
                color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.error_container : Colors.colors.surface_container_high

                RowLayout {
                    id: mainRow
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 14

                    Rectangle {
                        Layout.preferredWidth: 64
                        Layout.preferredHeight: 64
                        Layout.alignment: Qt.AlignTop
                        radius: 20
                        color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.error : Colors.colors.primary_container

                        Text {
                            anchors.centerIn: parent
                            text: "notifications"
                            font.family: Theme.settings.fontFamilyMaterial
                            font.pixelSize: 24
                            color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.on_error : Colors.colors.on_primary_container
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: (model.appName || "System").toUpperCase()
                                font {
                                    family: Theme.settings.fontFamily
                                    pixelSize: 9
                                    bold: true
                                    letterSpacing: 0.5
                                }
                                color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.on_error_container : Colors.colors.primary
                                Layout.fillWidth: true
                            }

                            MouseArea {
                                width: 24
                                height: 24
                                onClicked: wrapper.animateOut()
                                Text {
                                    anchors.centerIn: parent
                                    text: "\ue5cd"
                                    font.family: Theme.settings.fontFamilyMaterial
                                    font.pixelSize: 18
                                    color: Colors.colors.on_surface_variant
                                }
                            }
                        }

                        Text {
                            text: model.summary || ""
                            color: Colors.colors.on_surface
                            font {
                                family: Theme.settings.fontFamily
                                pixelSize: 14
                                bold: true
                            }
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        Text {
                            text: model.body || ""
                            color: Colors.colors.on_surface_variant
                            font {
                                family: Theme.settings.fontFamily
                                pixelSize: 12
                            }
                            wrapMode: Text.WordWrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            visible: text !== ""
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
