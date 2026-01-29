import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../core"

ColumnLayout {
    id: wifiView
    spacing: Theme.values.spacingM

    signal backRequested

    // --- Header ---
    RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        spacing: 10

        // Back Button
        Rectangle {
            width: 32
            height: 32
            radius: 16
            color: backMs.containsMouse ? Colors.colors.surface_container_highest : "transparent"
            Text {
                anchors.centerIn: parent
                text: "arrow_back"
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 20
                color: Colors.colors.on_surface
            }
            MouseArea {
                id: backMs
                anchors.fill: parent
                hoverEnabled: true
                onClicked: wifiView.backRequested()
            }
        }

        Text {
            text: "Wi-Fi"
            font.bold: true
            font.pixelSize: 18
            color: Colors.colors.on_surface
            Layout.fillWidth: true
        }

        // --- NEW: Toggle Switch ---
        Rectangle {
            id: toggleTrack
            width: 46
            height: 24
            radius: 12
            color: NetworkService.wifiEnabled ? Colors.colors.primary : Colors.colors.surface_container_highest

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }
            }

            Rectangle {
                id: toggleThumb
                width: 16
                height: 16
                radius: 8
                anchors.verticalCenter: parent.verticalCenter
                // Move thumb left or right based on state
                x: NetworkService.wifiEnabled ? parent.width - width - 4 : 4
                color: NetworkService.wifiEnabled ? Colors.colors.on_primary : Colors.colors.outline

                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutBack
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: NetworkService.toggleWifi(!NetworkService.wifiEnabled)
            }
        }
    }

    // --- Content Area ---
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true

        // 1. Network List (Visible when ON)
        ListView {
            id: wifiList
            anchors.fill: parent
            visible: NetworkService.wifiEnabled
            clip: true
            model: NetworkService.scanResults
            spacing: 4

            // (Reuse your Delegate from previous answer here)
            delegate: Rectangle {
                id: delegateRoot
                width: wifiList.width
                height: isSelected ? 100 : 48
                property bool isSelected: ListView.view.currentIndex === index
                property bool isConnected: modelData.active

                color: isConnected ? Colors.colors.primary_container : (delegateMs.containsMouse ? Colors.colors.surface_container_highest : Colors.colors.surface_container_high)
                radius: Theme.values.roundS

                Behavior on height {
                    NumberAnimation {
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 0

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 10
                        Text {
                            text: modelData.secure ? "lock" : "wifi"
                            font.family: Theme.values.fontFamilyMaterial
                            font.pixelSize: 18
                            color: isConnected ? Colors.colors.on_primary_container : Colors.colors.on_surface
                        }
                        Text {
                            text: modelData.ssid
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            font.bold: isConnected
                            color: isConnected ? Colors.colors.on_primary_container : Colors.colors.on_surface
                        }
                        Text {
                            visible: isConnected
                            text: "check"
                            font.family: Theme.values.fontFamilyMaterial
                            font.pixelSize: 18
                            color: Colors.colors.on_primary_container
                        }
                    }

                    // Password Input Area
                    Item {
                        visible: delegateRoot.isSelected && !modelData.active
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        RowLayout {
                            anchors.fill: parent
                            spacing: 8
                            TextField {
                                id: passField
                                Layout.fillWidth: true
                                placeholderText: "Password"
                                echoMode: TextInput.Password
                                color: Colors.colors.on_surface
                                background: Rectangle {
                                    color: Colors.colors.surface
                                    radius: 4
                                }
                            }
                            Rectangle {
                                width: 60
                                height: 30
                                color: Colors.colors.primary
                                radius: 4
                                Text {
                                    anchors.centerIn: parent
                                    text: "Join"
                                    color: Colors.colors.on_primary
                                    font.bold: true
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        NetworkService.connect(modelData.ssid, passField.text);
                                        wifiList.currentIndex = -1;
                                    }
                                }
                            }
                        }
                    }
                }
                MouseArea {
                    id: delegateMs
                    anchors.fill: parent
                    propagateComposedEvents: true
                    z: -1
                    hoverEnabled: true
                    onClicked: {
                        if (modelData.active)
                            NetworkService.disconnect();
                        else if (!modelData.secure)
                            NetworkService.connect(modelData.ssid, "");
                        else
                            wifiList.currentIndex = (wifiList.currentIndex === index) ? -1 : index;
                    }
                }
            }
        }

        // 2. "Off" State Message (Visible when OFF)
        ColumnLayout {
            anchors.centerIn: parent
            visible: !NetworkService.wifiEnabled
            spacing: 10

            Text {
                text: "wifi_off"
                font.family: Theme.values.fontFamilyMaterial
                font.pixelSize: 48
                color: Colors.colors.outline
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "Wi-Fi is turned off"
                font.bold: true
                font.pixelSize: 16
                color: Colors.colors.on_surface
                Layout.alignment: Qt.AlignHCenter
            }
            Text {
                text: "Turn on Wi-Fi to see available networks"
                font.pixelSize: 12
                color: Colors.colors.on_surface_variant
                Layout.alignment: Qt.AlignHCenter
            }
        }

        // 3. Busy Indicator (When scanning)
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.margins: 20
            width: 120
            height: 30
            radius: 15
            color: Colors.colors.inverse_surface
            opacity: NetworkService.isScanning ? 0.9 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                // Simple spinning circle
                Text {
                    text: "sync"
                    font.family: Theme.values.fontFamilyMaterial
                    color: Colors.colors.inverse_on_surface
                    RotationAnimation on rotation {
                        loops: Animation.Infinite
                        from: 0
                        to: 360
                        duration: 1000
                        running: NetworkService.isScanning
                    }
                }
                Text {
                    text: "Scanning..."
                    color: Colors.colors.inverse_on_surface
                    font.pixelSize: 12
                }
            }
        }
    }
}
