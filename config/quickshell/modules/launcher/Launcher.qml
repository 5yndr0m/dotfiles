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

    Rectangle {
        anchors.fill: parent
        color: Colors.colors.scrim
        opacity: launcherWindow.visible ? 0.3 : 0
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

    Rectangle {
        id: content
        anchors.centerIn: parent
        width: 500
        height: 420
        color: Colors.colors.surface
        radius: Theme.settings.roundL
        clip: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: Theme.settings.spacingM
            spacing: Theme.settings.spacingS

            Rectangle {
                Layout.fillWidth: true
                height: 48
                color: Colors.colors.surface_container_high
                radius: Theme.settings.roundM

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.settings.spacingM
                    spacing: Theme.settings.spacingS

                    Text {
                        text: "\ue8b6"
                        font.family: Theme.settings.fontFamilyMaterial
                        font.pixelSize: Theme.settings.iconSizeS
                        color: Colors.colors.on_surface_variant
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: Colors.colors.on_surface
                        font.family: Theme.settings.fontFamily
                        font.pixelSize: 16
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

            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: LauncherService.filteredApps
                spacing: 2
                clip: true

                delegate: Rectangle {
                    id: delegateRoot
                    width: appList.width
                    implicitHeight: Math.max(48, contentRow.implicitHeight + 16)
                    radius: Theme.settings.roundS
                    color: LauncherService.activeIndex === index ? Colors.colors.secondary_container : "transparent"

                    RowLayout {
                        id: contentRow
                        anchors.fill: parent
                        anchors.leftMargin: Theme.settings.spacingM
                        anchors.rightMargin: Theme.settings.spacingM
                        spacing: Theme.settings.spacingM

                        IconImage {
                            Layout.preferredWidth: Theme.settings.iconSizeM
                            Layout.preferredHeight: Theme.settings.iconSizeM
                            Layout.alignment: Qt.AlignVCenter
                            source: modelData.icon.startsWith("/") ? "file://" + modelData.icon : Quickshell.iconPath(modelData.icon || "application-x-executable")
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 0

                            Text {
                                text: modelData.name
                                color: LauncherService.activeIndex === index ? Colors.colors.on_secondary_container : Colors.colors.on_surface
                                font.family: Theme.settings.fontFamily
                                font.pixelSize: 14
                                font.weight: Font.DemiBold
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }

                            Text {
                                text: modelData.comment
                                color: LauncherService.activeIndex === index ? Colors.colors.on_secondary_container : Colors.colors.on_surface_variant
                                opacity: 0.8
                                font.family: Theme.settings.fontFamily
                                font.pixelSize: 10

                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true

                                visible: modelData.comment !== "" && modelData.comment !== "Application"
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
