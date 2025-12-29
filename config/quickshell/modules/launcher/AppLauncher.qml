import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
// import Quickshell.Services.DesktopEntries

import qs.config

PanelWindow {
    id: launcherWindow

    implicitWidth: 500
    implicitHeight: 450

    // Position in the center of the screen
    // anchors.center: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    property string query: ""
    readonly property var allApps: [...DesktopEntries.applications.values]

    Rectangle {
        anchors.fill: parent
        color: ThemeAuto.bgSurface
        radius: 20 // More rounded for M3 look
        border.color: ThemeAuto.outline
        border.width: 1

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16

            // --- Search Field ---
            TextField {
                id: searchInput
                Layout.fillWidth: true
                placeholderText: "Search applications..."
                placeholderTextColor: ThemeAuto.textSecondary
                color: ThemeAuto.textMain
                focus: true
                font { family: "Google Sans"; pixelSize: 16 }

                background: Rectangle {
                    color: ThemeAuto.bgContainer
                    radius: 12
                    border.color: searchInput.activeFocus ? ThemeAuto.accent : "transparent"
                    border.width: 2
                }

                onTextChanged: launcherWindow.query = text

                onAccepted: {
                    if (resultsList.count > 0) {
                        resultsList.currentItem.launch();
                    }
                }

                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) launcherWindow.visible = false;
                    if (event.key === Qt.Key_Down) resultsList.currentIndex = (resultsList.currentIndex + 1) % resultsList.count;
                    if (event.key === Qt.Key_Up) resultsList.currentIndex = (resultsList.currentIndex - 1 + resultsList.count) % resultsList.count;
                }
            }

            // --- Results List ---
            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                currentIndex: 0
                cacheBuffer: 2000

                model: ScriptModel {
                    values: {
                        const q = launcherWindow.query.toLowerCase().trim();
                        if (q === "") return launcherWindow.allApps;
                        return launcherWindow.allApps.filter(app =>
                            app.name.toLowerCase().includes(q) ||
                            (app.genericName && app.genericName.toLowerCase().includes(q))
                        );
                    }
                }

                delegate: Rectangle {
                    id: delegateRoot
                    width: resultsList.width
                    height: 48
                    radius: 10

                    // Selection highlight
                    color: ListView.isCurrentItem ? ThemeAuto.accent : "transparent"

                    function launch() {
                        modelData.execute();
                        launcherWindow.visible = false;
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        // Small dot indicator for active focus
                        Rectangle {
                            width: 4; height: 16; radius: 2
                            color: ThemeAuto.bgSurface
                            visible: ListView.isCurrentItem
                        }

                        Text {
                            text: modelData.name
                            color: ListView.isCurrentItem ? ThemeAuto.bgSurface : ThemeAuto.textMain
                            font {
                                family: "Google Sans";
                                pixelSize: 14;
                                weight: ListView.isCurrentItem ? Font.Bold : Font.Normal
                            }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: delegateRoot.launch()
                        onEntered: resultsList.currentIndex = index
                    }
                }

                // Empty State
                Text {
                    anchors.centerIn: parent
                    text: "No applications found"
                    visible: resultsList.count === 0
                    color: ThemeAuto.textSecondary
                    font { family: "Google Sans"; pixelSize: 14 }
                }
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            query = "";
            searchInput.text = "";
            Qt.callLater(() => searchInput.forceActiveFocus());
        }
    }
}
