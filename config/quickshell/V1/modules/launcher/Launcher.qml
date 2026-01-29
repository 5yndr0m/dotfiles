import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "../../core"
import qs.components

PanelWindow {
    id: launcherWindow

    color: "transparent"
    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    onVisibleChanged: {
        if (visible) {
            searchInput.text = "";
            Qt.callLater(() => searchInput.forceActiveFocus());
        }
    }

    property int itemHeight: 50
    property int visibleItems: 2

    MouseArea {
        anchors.fill: parent
        onClicked: launcherWindow.visible = false
    }

    CornerShape {
        id: leftCorner
        width: 64
        height: 64
        anchors.right: launcherBox.left
        anchors.bottom: launcherBox.bottom
        color: launcherBox.color
        radius: width
        orientation: 3
    }

    CornerShape {
        id: rightCorner
        width: 64
        height: 64
        anchors.left: launcherBox.right
        anchors.bottom: launcherBox.bottom
        color: launcherBox.color
        radius: width
        orientation: 2
    }

    Rectangle {
        id: launcherBox
        width: 500
        height: layout.implicitHeight

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter

        color: Colors.colors.surface
        topLeftRadius: Theme.values.roundL
        topRightRadius: Theme.values.roundL
        bottomLeftRadius: 0
        bottomRightRadius: 0

        clip: true

        MouseArea {
            anchors.fill: parent
            hoverEnabled: false
        }

        ColumnLayout {
            id: layout
            anchors.fill: parent
            spacing: 0

            ListView {
                id: resultsList
                Layout.fillWidth: true
                Layout.fillHeight: false
                Layout.preferredHeight: launcherWindow.visibleItems * launcherWindow.itemHeight
                Layout.topMargin: 10
                Layout.bottomMargin: 10

                interactive: true
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                model: LauncherService.resultsModel
                currentIndex: 0
                verticalLayoutDirection: ListView.BottomToTop

                delegate: Rectangle {
                    width: resultsList.width
                    height: launcherWindow.itemHeight
                    radius: Theme.values.roundS
                    color: (ListView.isCurrentItem || mouseArea.containsMouse) ? Colors.colors.surface_container_high : "transparent"

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            launcherWindow.visible = false;
                            LauncherService.launch(index);
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Theme.values.paddingL
                        anchors.rightMargin: Theme.values.paddingL
                        spacing: Theme.values.spacingM

                        Image {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            source: (model.icon && model.icon.indexOf("/") === -1) ? "image://icon/" + model.icon : (model.icon || "")
                            visible: status === Image.Ready
                        }
                        Text {
                            Layout.fillWidth: true
                            text: model.name
                            color: Colors.colors.on_surface
                            font.family: Theme.values.fontFamily
                            font.pixelSize: 14
                            Layout.alignment: Qt.AlignVCenter
                        }
                    }
                }
            }

            // Rectangle {
            //     Layout.fillWidth: true
            //     Layout.preferredHeight: 1
            //     color: Colors.colors.outline_variant
            //     visible: true
            // }

            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                Layout.margins: Theme.values.paddingL
                spacing: Theme.values.spacingM

                Text {
                    text: "search"
                    font.family: Theme.values.fontFamilyMaterial
                    font.pixelSize: 20
                    color: Colors.colors.primary
                    Layout.alignment: Qt.AlignVCenter
                }

                TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    color: Colors.colors.on_surface
                    font.family: Theme.values.fontFamily
                    font.pixelSize: 16
                    focus: true
                    placeholderText: "Search..."
                    placeholderTextColor: Colors.colors.on_surface_variant
                    background: Item {}
                    onTextChanged: LauncherService.search(text)

                    onAccepted: {
                        launcherWindow.visible = false;
                        if (LauncherService.resultsModel.count > 0) {
                            var idx = resultsList.currentIndex >= 0 ? resultsList.currentIndex : 0;
                            LauncherService.launch(idx);
                        }
                    }

                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_Escape) {
                            launcherWindow.visible = false;
                        } else if (event.key === Qt.Key_Down) {
                            resultsList.decrementCurrentIndex();
                        } else if (event.key === Qt.Key_Up) {
                            resultsList.incrementCurrentIndex();
                        }
                    }
                }
            }
        }
    }
}
