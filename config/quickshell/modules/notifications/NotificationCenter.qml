import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import qs.services.notifs
import qs.config
import qs.Components

PanelWindow {
    id: notifCenter
    anchors.top: true
    implicitWidth: 450 + 96
    implicitHeight: 400 // Increased height for better scroll view
    color: "transparent"

    property bool isOpen: false
    visible: isOpen || animationWrapper.opacity > 0
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Item {
        id: animationWrapper
        anchors.fill: parent
        anchors.topMargin: 30
        opacity: notifCenter.isOpen ? 1 : 0

        transform: Translate {
            y: (animationWrapper.opacity - 1) * 30
        }

        Behavior on opacity {
            NumberAnimation { duration: 300; easing.type: Easing.OutQuint }
        }

        // --- Corner Aesthetics ---
        CornerShape {
            anchors.right: mainContainer.left
            anchors.top: mainContainer.top
            color: ThemeAuto.bgSurface
            radius: 24; orientation: 1; width: 48; height: 48
        }

        CornerShape {
            anchors.left: mainContainer.right
            anchors.top: mainContainer.top
            color: ThemeAuto.bgSurface
            radius: 24; orientation: 0; width: 48; height: 48
        }

        Rectangle {
            id: mainContainer
            width: 450
            anchors.top: parent.top; anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: ThemeAuto.bgSurface
            bottomLeftRadius: 24; bottomRightRadius: 24
            clip: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 20
                spacing: 15

                // --- Header Section ---
                RowLayout {
                    Layout.fillWidth: true
                    Layout.bottomMargin: 5

                    ColumnLayout {
                        spacing: 0
                        Text {
                            text: "History"
                            color: ThemeAuto.textMain
                            font { pixelSize: 22; weight: Font.Bold; family: "Google Sans" }
                        }
                        Text {
                            text: Notifs.historyModel.count + " notifications saved"
                            color: ThemeAuto.textSecondary
                            font { pixelSize: 12; family: "Google Sans" }
                        }
                    }

                    Item { Layout.fillWidth: true }

                    // --- Clear All Button ---
                    Item {
                        id: clearAllBtn
                        Layout.preferredWidth: btnContent.implicitWidth + 28
                        Layout.preferredHeight: 32
                        Layout.alignment: Qt.AlignVCenter

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: ThemeAuto.accent
                            opacity: clearAllMouse.containsMouse ? 0.2 : 0.1
                            border.color: ThemeAuto.accent
                            border.width: 1
                            Behavior on opacity { NumberAnimation { duration: 200 } }
                        }

                        RowLayout {
                            id: btnContent
                            anchors.centerIn: parent
                            spacing: 6
                            Text {
                                text: "delete_sweep"
                                font { family: "Material Symbols Rounded"; pixelSize: 18 }
                                color: ThemeAuto.accent
                            }
                            Text {
                                text: "Clear All"
                                color: ThemeAuto.accent
                                font { weight: Font.Medium; family: "Google Sans"; pixelSize: 13 }
                            }
                        }

                        MouseArea {
                            id: clearAllMouse
                            anchors.fill: parent
                            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: Notifs.clearHistory()
                        }
                    }
                }

                // --- Scrollable History List ---
                ListView {
                    id: historyList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    model: Notifs.historyModel
                    spacing: 10
                    clip: true
                    visible: count > 0

                    ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

                    delegate: Rectangle {
                        id: delegateRoot
                        width: historyList.width
                        height: contentCol.implicitHeight + 24
                        color: ThemeAuto.bgContainer
                        radius: 16
                        border.color: ThemeAuto.outline
                        border.width: 0.5

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12

                            ColumnLayout {
                                id: contentCol
                                Layout.fillWidth: true
                                spacing: 4

                                RowLayout {
                                    spacing: 8
                                    Text {
                                        text: model.appName || "System"
                                        color: ThemeAuto.accent
                                        font { pixelSize: 11; weight: Font.Bold; family: "Google Sans" }
                                    }
                                    Text {
                                        text: "•"
                                        color: ThemeAuto.outline
                                    }
                                    Text {
                                        text: Notifs.formatTimestamp(model.timestamp)
                                        color: ThemeAuto.textSecondary
                                        font { pixelSize: 11; family: "Google Sans" }
                                    }
                                }

                                Text {
                                    text: model.summary
                                    color: ThemeAuto.textMain
                                    font { pixelSize: 14; weight: Font.Bold; family: "Google Sans" }
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                }

                                Text {
                                    text: model.body
                                    color: ThemeAuto.textSecondary
                                    font { pixelSize: 13; family: "Google Sans" }
                                    wrapMode: Text.Wrap; maximumLineCount: 2
                                    elide: Text.ElideRight; Layout.fillWidth: true
                                }
                            }

                            // --- Close Button ---
                            Item {
                                Layout.preferredWidth: 28; Layout.preferredHeight: 28
                                Layout.alignment: Qt.AlignTop

                                Rectangle {
                                    anchors.fill: parent; radius: 14
                                    color: ThemeAuto.textMain
                                    opacity: closeMouse.containsMouse ? 0.1 : 0
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "close"
                                    font { family: "Material Symbols Rounded"; pixelSize: 18 }
                                    color: closeMouse.containsMouse ? ThemeAuto.accent : ThemeAuto.outline
                                }

                                MouseArea {
                                    id: closeMouse
                                    anchors.fill: parent; hoverEnabled: true
                                    onClicked: {
                                        Notifs.historyModel.remove(index);
                                        Notifs.saveHistory();
                                    }
                                }
                            }
                        }
                    }
                }

                // --- Empty State Placeholder ---
                ColumnLayout {
                    visible: historyList.count === 0
                    Layout.fillWidth: true; Layout.fillHeight: true
                    spacing: 10

                    Item { Layout.fillHeight: true }

                    Text {
                        text: "notifications_off"
                        font { family: "Material Symbols Rounded"; pixelSize: 48 }
                        color: ThemeAuto.outline
                        Layout.alignment: Qt.AlignHCenter
                    }
                    Text {
                        text: "Your history is clear"
                        color: ThemeAuto.outline
                        font { pixelSize: 16; family: "Google Sans" }
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Item { Layout.fillHeight: true }
                }
            }
        }
    }
}
