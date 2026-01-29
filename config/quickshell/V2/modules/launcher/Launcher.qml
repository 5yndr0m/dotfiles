import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../../core"

PanelWindow {
    id: launcherWindow
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    visible: false
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    onVisibleChanged: {
        if (visible) {
            LauncherService.searchText = "";
            LauncherService.activeIndex = 0;
            searchInput.text = "";
            searchInput.forceActiveFocus();
            appList.positionViewAtBeginning();
        }
    }

    function toggle() {
        if (visible) {
            closeAnim.start();
        } else {
            launcherWindow.visible = true;
            openAnim.start();
        }
    }

    // --- Animations ---
    ParallelAnimation {
        id: openAnim
        NumberAnimation {
            target: content
            property: "opacity"
            from: 0
            to: 1
            duration: 150
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: content
            property: "scale"
            from: 0.98
            to: 1
            duration: 150
            easing.type: Easing.OutCubic
        }
    }

    SequentialAnimation {
        id: closeAnim
        ParallelAnimation {
            NumberAnimation {
                target: content
                property: "opacity"
                to: 0
                duration: 100
            }
            NumberAnimation {
                target: content
                property: "scale"
                to: 0.98
                duration: 100
            }
        }
        ScriptAction {
            script: {
                launcherWindow.visible = false;
            }
        }
    }

    // Background Dim
    Rectangle {
        anchors.fill: parent
        color: Colors.colors.scrim
        opacity: launcherWindow.visible ? 0.3 : 0 // Lighter dim for a compact feel
        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
        MouseArea {
            anchors.fill: parent
            onClicked: launcherWindow.toggle()
        }
    }

    // Main Compact Container
    Rectangle {
        id: content
        anchors.centerIn: parent
        width: 500  // Shrunk from 650
        height: 420 // Shrunk from 500
        color: Colors.colors.surface
        radius: Theme.settings.roundL // Slightly smaller rounding for compact look
        border.color: Colors.colors.outline_variant
        border.width: 1
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.settings.spacingM // Thinner margins
            spacing: Theme.settings.spacingS

            // Compact Search Bar
            Rectangle {
                Layout.fillWidth: true
                height: 48 // Shrunk from 60
                color: Colors.colors.surface_container_high
                radius: Theme.settings.roundM

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.settings.spacingM
                    spacing: Theme.settings.spacingS

                    Text {
                        text: "\ue8b6"
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: Theme.settings.iconSizeS // Smaller icon
                        color: Colors.colors.on_surface_variant
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: Colors.colors.on_surface
                        font.family: Theme.settings.fontFamily
                        font.pixelSize: 16 // Shrunk from 20
                        focus: launcherWindow.visible
                        onTextChanged: LauncherService.searchText = text

                        Keys.onPressed: event => {
                            let count = LauncherService.filteredApps.length;
                            if (event.key === Qt.Key_Escape)
                                launcherWindow.toggle();

                            if (event.key === Qt.Key_Down) {
                                LauncherService.activeIndex = (LauncherService.activeIndex + 1) % count;
                                appList.positionViewAtIndex(LauncherService.activeIndex, ListView.Contain);
                            }
                            if (event.key === Qt.Key_Up) {
                                LauncherService.activeIndex = (LauncherService.activeIndex - 1 + count) % count;
                                appList.positionViewAtIndex(LauncherService.activeIndex, ListView.Contain);
                            }
                            if (event.key === Qt.Key_Return && count > 0) {
                                Quickshell.execDetached(["sh", "-c", LauncherService.filteredApps[LauncherService.activeIndex].exec]);
                                closeAnim.start();
                            }
                        }
                    }
                }
            }

            // Compact App List
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: LauncherService.filteredApps
                spacing: 2 // Tighter spacing
                clip: true

                delegate: Rectangle {
                    width: appList.width
                    height: 48 // Shrunk from 64
                    radius: Theme.settings.roundS
                    color: LauncherService.activeIndex === index ? Colors.colors.secondary_container : "transparent"

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.settings.spacingS
                        spacing: Theme.settings.spacingM

                        IconImage {
                            Layout.preferredWidth: Theme.settings.iconSizeM // Shrunk from iconSizeL
                            Layout.preferredHeight: Theme.settings.iconSizeM
                            source: modelData.icon.startsWith("/") ? "file://" + modelData.icon : Quickshell.iconPath(modelData.icon || "application-x-executable")
                        }

                        Column {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            Text {
                                text: modelData.name
                                color: LauncherService.activeIndex === index ? Colors.colors.on_secondary_container : Colors.colors.on_surface
                                font.family: Theme.settings.fontFamily
                                font.pixelSize: 14 // Shrunk from 15
                                font.weight: Font.DemiBold
                            }
                            // Only show comment if there is space, or hide for extreme compactness
                            Text {
                                text: modelData.comment
                                color: Colors.colors.on_surface_variant
                                font.family: Theme.settings.fontFamily
                                font.pixelSize: 10
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                                visible: modelData.comment !== "Application" // Hide generic comments
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: LauncherService.activeIndex = index
                        onClicked: {
                            Quickshell.execDetached(["sh", "-c", modelData.exec]);
                            closeAnim.start();
                        }
                    }
                }
            }
        }
    }
}
