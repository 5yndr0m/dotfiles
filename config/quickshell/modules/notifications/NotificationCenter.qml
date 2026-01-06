import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import "../../core"
import qs.components

PanelWindow {
    id: notifCenter

    anchors.top: true
    implicitWidth: 450 + (Theme.values ? Theme.values.spacingXL * 4 : 40)
    implicitHeight: 400
    color: "transparent"

    visible: false
    property bool shouldBeVisible: false

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    function open() {
        if (!visible)
            visible = true;
        closeTimer.stop();
    }

    function close() {
        if (visible)
            shouldBeVisible = false;
    }

    HoverHandler {
        id: mainHover
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onHoveredChanged: {
            if (hovered)
                closeTimer.stop();
            else
                closeTimer.start();
        }
    }

    MouseArea {
        anchors.fill: parent
        z: -1
        hoverEnabled: false
        onPressed: mouse => mouse.accepted = true
    }

    Timer {
        id: closeTimer
        interval: 400
        onTriggered: {
            if (!mainHover.hovered)
                notifCenter.close();
        }
    }

    Item {
        id: animationWrapper
        anchors.fill: parent
        anchors.topMargin: 32

        opacity: shouldBeVisible ? 1 : 0
        transform: Translate {
            y: (animationWrapper.opacity - 1) * 20
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 300
                easing.type: Easing.OutCubic
            }
        }

        onOpacityChanged: {
            if (opacity === 0 && visible) {
                notifCenter.visible = false;
            }
        }

        CornerShape {
            anchors.right: mainContainer.left
            anchors.top: mainContainer.top
            color: Colors.colors.surface_container
            radius: Theme.values.roundXL
            orientation: 1
            width: 48
            height: 48
        }

        CornerShape {
            anchors.left: mainContainer.right
            anchors.top: mainContainer.top
            color: Colors.colors.surface_container
            radius: Theme.values.roundXL
            orientation: 0
            width: 48
            height: 48
        }

        Rectangle {
            id: mainContainer
            width: 450
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colors.colors.surface_container
            bottomLeftRadius: Theme.values.roundXL
            bottomRightRadius: Theme.values.roundXL
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Theme.values.spacingXL
                spacing: Theme.values.spacingM

                RowLayout {
                    Layout.fillWidth: true
                    ColumnLayout {
                        spacing: Theme.values.spacingXS
                        Text {
                            text: "History"
                            color: Colors.colors.on_surface
                            font {
                                family: Theme.values.fontFamily
                                pixelSize: 24
                                weight: Font.Bold
                            }
                        }
                        Text {
                            text: NotificationService.historyModel.count + " notifications"
                            color: Colors.colors.on_surface_variant
                            font {
                                family: Theme.values.fontFamily
                                pixelSize: 12
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    Control {
                        id: clearAllBtn
                        padding: Theme.values.paddingS
                        background: Rectangle {
                            radius: Theme.values.roundFull
                            color: clearAllBtn.hovered ? Colors.colors.error_container : "transparent"
                            border.color: Colors.colors.error
                            border.width: 1
                        }
                        contentItem: RowLayout {
                            spacing: Theme.values.spacingS
                            Text {
                                text: "delete_sweep"
                                font {
                                    family: Theme.values.fontFamilyMaterial
                                    pixelSize: Theme.values.iconSizeS
                                }
                                color: Colors.colors.error
                            }
                            Text {
                                text: "Clear All"
                                color: Colors.colors.error
                                font {
                                    family: Theme.values.fontFamily
                                    weight: Font.Medium
                                    pixelSize: 13
                                }
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: NotificationService.clearHistory()
                        }
                    }
                }

                ListView {
                    id: historyList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: NotificationService.historyModel
                    spacing: Theme.values.spacingS
                    clip: true
                    visible: count > 0

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                        // active: historyList.moving || historyList.hovered
                    }

                    delegate: Rectangle {
                        id: delegateRoot
                        width: historyList.width
                        height: contentCol.implicitHeight + (Theme.values.spacingM * 2)

                        color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.error_container : Colors.colors.surface_container_low

                        radius: Theme.values.roundL
                        border.color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.error : Colors.colors.outline_variant
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: Theme.values.spacingM
                            spacing: Theme.values.spacingM

                            ColumnLayout {
                                id: contentCol
                                Layout.fillWidth: true
                                spacing: Theme.values.spacingXS

                                RowLayout {
                                    Text {
                                        text: model.appName || "System"
                                        color: (model.urgency === NotificationUrgency.Critical) ? Colors.colors.error : Colors.colors.primary
                                        font {
                                            pixelSize: 11
                                            weight: Font.Bold
                                            family: Theme.values.fontFamily
                                        }
                                    }
                                    Text {
                                        text: "• " + NotificationService.formatTimestamp(model.timestamp)
                                        color: Colors.colors.on_surface_variant
                                        font {
                                            pixelSize: 11
                                            family: Theme.values.fontFamily
                                        }
                                    }
                                }

                                Text {
                                    text: model.summary
                                    color: Colors.colors.on_surface
                                    font {
                                        pixelSize: 15
                                        weight: Font.Medium
                                        family: Theme.values.fontFamily
                                    }
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: model.body
                                    color: Colors.colors.on_surface_variant
                                    font {
                                        pixelSize: 13
                                        family: Theme.values.fontFamily
                                    }
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 3
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }

                            Text {
                                text: "close"
                                font {
                                    family: Theme.values.fontFamilyMaterial
                                    pixelSize: 18
                                }
                                color: closeMouse.containsMouse ? Colors.colors.primary : Colors.colors.outline
                                Layout.alignment: Qt.AlignTop

                                MouseArea {
                                    id: closeMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor

                                    onClicked: NotificationService.removeHistoryAt(index)
                                }
                            }
                        }
                    }
                }

                ColumnLayout {
                    visible: historyList.count === 0
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.values.spacingS

                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                    Text {
                        text: "notifications_off"
                        font {
                            family: Theme.values.fontFamilyMaterial
                            pixelSize: 48
                        }
                        color: Colors.colors.outline_variant
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Your history is clear"
                        color: Colors.colors.on_surface_variant
                        font {
                            family: Theme.values.fontFamily
                            pixelSize: 14
                        }
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Item {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible)
            shouldBeVisible = true;
    }
}
