import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import Quickshell.Hyprland
import "../../core"

Item {
    id: rootItem

    readonly property var colors: Colors.colors
    readonly property var tokens: Theme.values

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
        margins.top: tokens.spacingL + 20
        margins.right: tokens.spacingL

        implicitWidth: 340
        implicitHeight: notificationStack.height

        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        // Animation Settings
        readonly property int animDuration: 300
        readonly property int animCurve: Easing.OutQuint

        Component.onCompleted: {
            NotificationService.animateAndRemove.connect((notification, index) => {
                if (index >= 0 && index < notificationStack.children.length) {
                    const delegate = notificationStack.children[index];
                    if (delegate && delegate.animateOut)
                        delegate.animateOut();
                }
            });
        }

        Column {
            id: notificationStack
            width: 310
            spacing: tokens.spacingM

            // Handles the smooth upward shuffling when a gap is created
            move: Transition {
                NumberAnimation {
                    properties: "y"
                    duration: root.animDuration
                    easing.type: root.animCurve
                }
            }

            Repeater {
                model: NotificationService.notificationModel

                delegate: Item {
                    id: delegateWrapper
                    width: 310
                    // Height is calculated naturally, but we control it during the exit animation
                    height: Math.round(each.height + tokens.spacingS)
                    clip: true // Important: Clips content during the slide/shrink

                    // --- 1. Initial State (Hidden off-screen to the right) ---
                    x: 340
                    opacity: 0

                    // --- 2. Entry Animation (Slide In) ---
                    Component.onCompleted: entryAnim.start()

                    ParallelAnimation {
                        id: entryAnim

                        NumberAnimation {
                            target: delegateWrapper
                            property: "x"
                            to: 0
                            duration: root.animDuration
                            easing.type: root.animCurve
                        }
                        NumberAnimation {
                            target: delegateWrapper
                            property: "opacity"
                            to: 1
                            duration: root.animDuration
                            easing.type: root.animCurve
                        }
                    }

                    // --- 3. Exit Animation (Slide Out -> Collapse) ---
                    function animateOut() {
                        exitAnim.start();
                    }

                    SequentialAnimation {
                        id: exitAnim

                        // Step A: Slide out to the right
                        ParallelAnimation {
                            NumberAnimation {
                                target: delegateWrapper
                                property: "x"
                                to: 340
                                duration: root.animDuration
                                easing.type: root.animCurve
                            }
                            NumberAnimation {
                                target: delegateWrapper
                                property: "opacity"
                                to: 0
                                duration: root.animDuration
                                easing.type: Easing.Linear
                            }
                        }

                        // Step B: Collapse height to close the gap
                        NumberAnimation {
                            target: delegateWrapper
                            property: "height"
                            to: 0
                            duration: root.animDuration
                            easing.type: root.animCurve
                        }

                        // Step C: Actually remove from data
                        ScriptAction {
                            script: NotificationService.forceRemoveNotification(model.rawNotification)
                        }
                    }

                    Rectangle {
                        id: each
                        width: delegateWrapper.width
                        height: contentColumn.implicitHeight + (tokens.paddingL * 2)
                        radius: tokens.roundL

                        color: (model.urgency === NotificationUrgency.Critical) ? colors.error_container : colors.surface_container
                        border.color: (model.urgency === NotificationUrgency.Critical) ? colors.error : colors.outline_variant
                        border.width: 1

                        DropShadow {
                            anchors.fill: each
                            radius: 8
                            color: colors.shadow
                            source: each
                            opacity: 0.3
                            z: -1
                            visible: each.opacity > 0
                            cached: true
                        }

                        HoverHandler {
                            onHoveredChanged: {
                                if (hovered && model.rawNotification && model.rawNotification.resetTimeout) {
                                    model.rawNotification.resetTimeout();
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (model.rawNotification && model.rawNotification.invokeDefaultAction) {
                                    model.rawNotification.invokeDefaultAction();
                                } else {
                                    delegateWrapper.animateOut();
                                }
                            }
                        }

                        ColumnLayout {
                            id: contentColumn
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.margins: tokens.paddingL
                            spacing: tokens.spacingS

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: tokens.spacingS

                                Text {
                                    text: (model.appName || "System").toUpperCase()
                                    color: (model.urgency === NotificationUrgency.Critical) ? colors.on_error_container : colors.primary
                                    font {
                                        pixelSize: 10
                                        bold: true
                                        family: tokens.fontFamily
                                    }
                                }

                                Item {
                                    Layout.fillWidth: true
                                }

                                Text {
                                    text: NotificationService.formatTimestamp(model.timestamp)
                                    color: colors.on_surface_variant
                                    font {
                                        pixelSize: 10
                                        family: tokens.fontFamily
                                    }
                                }

                                MouseArea {
                                    width: 16
                                    height: 16
                                    cursorShape: Qt.PointingHandCursor
                                    z: 2
                                    onClicked: delegateWrapper.animateOut()
                                    Text {
                                        anchors.centerIn: parent
                                        text: "close"
                                        font {
                                            family: tokens.fontFamilyMaterial
                                            pixelSize: 16
                                        }
                                        color: parent.containsMouse ? colors.primary : colors.outline
                                    }
                                }
                            }

                            Text {
                                text: model.summary || ""
                                font {
                                    pixelSize: 14
                                    weight: Font.DemiBold
                                    family: tokens.fontFamily
                                }
                                color: (model.urgency === NotificationUrgency.Critical) ? colors.on_error_container : colors.on_surface
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: model.body || ""
                                font {
                                    pixelSize: 12
                                    family: tokens.fontFamily
                                }
                                color: colors.on_surface_variant
                                wrapMode: Text.Wrap
                                Layout.fillWidth: true
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: text !== ""
                            }

                            Flow {
                                Layout.fillWidth: true
                                Layout.topMargin: 4
                                spacing: 8

                                visible: (model.rawNotification !== undefined) && (model.rawNotification.actions !== undefined) && (model.rawNotification.actions.length > 0)

                                Repeater {
                                    model: (parent.visible) ? model.rawNotification.actions : []

                                    delegate: Rectangle {
                                        width: actionTxt.implicitWidth + 24
                                        height: 26
                                        radius: 13
                                        color: actionMouse.containsMouse ? colors.secondary_container : "transparent"
                                        border.color: colors.outline
                                        border.width: 1

                                        MouseArea {
                                            id: actionMouse
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (modelData && modelData.invoke) {
                                                    modelData.invoke();
                                                    delegateWrapper.animateOut();
                                                }
                                            }
                                        }

                                        Text {
                                            id: actionTxt
                                            anchors.centerIn: parent
                                            text: modelData.label || "Action"
                                            font.pixelSize: 11
                                            color: colors.on_surface
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
}
