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

    // Fixed height for ~3-4 notifications (adjust 450 to your preference)
    implicitWidth: 360
    implicitHeight: 600

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    ListView {
        id: notificationList
        anchors.fill: parent
        model: NotificationService.notificationModel
        spacing: 12
        interactive: false // Popups shouldn't scroll manually
        clip: true

        // This handles the "Slide Up" when an item is removed
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

            // This connects each individual popup to the global service signal
            Connections {
                target: NotificationService
                function onAnimateAndRemove(notification, index) {
                    // Only trigger if this specific delegate holds the notification being removed
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
                height: layout.implicitHeight + 24
                radius: Theme.settings.roundM
                color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.error_container : Colors.colors.surface_container_high
                border.color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.error : Colors.colors.outline_variant
                border.width: 1

                ColumnLayout {
                    id: layout
                    anchors {
                        fill: parent
                        margins: 12
                    }
                    spacing: 4

                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: (model.appName || "System").toUpperCase()
                            font {
                                family: Theme.settings.fontFamily
                                pixelSize: 9
                                bold: true
                            }
                            color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.on_error_container : Colors.colors.primary
                            Layout.fillWidth: true
                        }
                        MouseArea {
                            width: 20
                            height: 20
                            onClicked: wrapper.animateOut()
                            Text {
                                anchors.centerIn: parent
                                text: "\ue5cd"
                                font {
                                    family: Theme.settings.fontFamilyMaterial
                                    pixelSize: 16
                                }
                                color: Colors.colors.on_surface_variant
                            }
                        }
                    }

                    Text {
                        text: model.summary || ""
                        color: Colors.colors.on_surface
                        font {
                            family: Theme.settings.fontFamily
                            pixelSize: 13
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
                            pixelSize: 11
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
