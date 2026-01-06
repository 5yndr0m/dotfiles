import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs.components
import "../../core"

PanelWindow {
    id: pickerWindow

    implicitWidth: 800 + (Theme.values.spacingXL * 8)
    implicitHeight: 180 + (Theme.values.spacingXL * 4)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    visible: false
    color: "transparent"
    anchors.bottom: true

    onVisibleChanged: {
        if (!visible) {
            wallpaperPickerLoader.active = false;

        }
    }

    FileView {
        id: wallpaperConfig
        path: Quickshell.env("HOME") + "/.config/quickshell/config/wallpaper.json"

        JsonAdapter {
            id: jsonStore
            property string currentPath: ""
            onCurrentPathChanged: wallpaperConfig.writeAdapter()
        }
    }

    Process { id: runner }

    function setWallpaper(path) {
        let cleanPath = decodeURIComponent(path.toString().replace(/^file:\/\//, ""));
        jsonStore.currentPath = cleanPath;
        syncCurrentIndex();

        runner.command = ["swww", "img", cleanPath, "--transition-type", "grow"];
        runner.startDetached();

        runner.command = ["matugen", "image", cleanPath];
        runner.startDetached();

        pickerWindow.visible = false;
    }

    function syncCurrentIndex() {
        if (folderModel.count === 0) return;
        let folderPath = decodeURIComponent(folderModel.folder.toString().replace(/^file:\/\//, ""));
        if (folderPath.endsWith("/")) folderPath = folderPath.slice(0, -1);

        for (let i = 0; i < folderModel.count; i++) {
            let name = folderModel.get(i, "fileName");
            let fullPath = folderPath + "/" + name;
            if (fullPath === jsonStore.currentPath) {
                view.currentIndex = i;
                return;
            }
        }
    }

    function forceCenter() {
        if (view.width <= 0) return;
        syncCurrentIndex();
        view.positionViewAtIndex(view.currentIndex, ListView.Center);
    }

    Item {
        anchors.fill: parent

        CornerShape {
            anchors.right: mainContainer.left
            anchors.bottom: mainContainer.bottom
            color: Colors.colors.surface_container
            radius: 48
            orientation: 3
            width: 96
            height: 96
        }

        CornerShape {
            anchors.left: mainContainer.right
            anchors.bottom: mainContainer.bottom
            color: Colors.colors.surface_container
            radius: 48
            orientation: 2
            width: 96
            height: 96
        }

        Rectangle {
            id: mainContainer
            width: 850
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colors.colors.surface_container
            clip: true
            topLeftRadius: Theme.values.roundL
            topRightRadius: Theme.values.roundL
            focus: true

            Keys.onLeftPressed: view.decrementCurrentIndex()
            Keys.onRightPressed: view.incrementCurrentIndex()
            Keys.onReturnPressed: if (view.currentItem) setWallpaper(view.currentItem.imageSource)
            Keys.onEscapePressed: pickerWindow.visible = false

            ListView {
                id: view
                anchors.fill: parent
                anchors.margins: 25
                orientation: ListView.Horizontal
                spacing: 20
                clip: true
                highlightMoveDuration: 450
                snapMode: ListView.SnapToItem
                keyNavigationWraps: true
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: (width / 2) - (expandedWidth / 2)
                preferredHighlightEnd: (width / 2) + (expandedWidth / 2)

                readonly property real expandedWidth: 400
                readonly property real collapsedWidth: 160

                model: FolderListModel {
                    id: folderModel
                    folder: "file://" + Quickshell.env("HOME") + "/Pictures/wallpapers"
                    nameFilters: ["*.jpg", "*.png", "*.webp", "*.jpeg"]
                    onStatusChanged: if (status === FolderListModel.Ready) Qt.callLater(forceCenter)
                }

                delegate: Item {
                    id: wrapper
                    readonly property string imageSource: folderModel.folder + "/" + fileName
                    height: view.height
                    width: ListView.isCurrentItem ? view.expandedWidth : view.collapsedWidth
                    clip: true
                    z: ListView.isCurrentItem ? 10 : 1

                    Behavior on width {
                        NumberAnimation { duration: 450; easing.type: Easing.OutQuint }
                    }

                    Rectangle {
                        id: imageContainer
                        anchors.fill: parent
                        radius: 16
                        color: Colors.colors.surface
                        clip: true
                        border.color: wrapper.ListView.isCurrentItem ? Colors.colors.primary : Colors.colors.outline
                        border.width: wrapper.ListView.isCurrentItem ? 3 : 1

                        Rectangle {
                            id: maskRect
                            anchors.fill: parent
                            radius: 16
                            visible: false
                        }

                        Image {
                            id: wallpaperImg
                            anchors.fill: parent
                            anchors.margins: parent.border.width
                            source: imageSource
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 300
                            asynchronous: true
                            visible: false
                            opacity: wrapper.ListView.isCurrentItem ? 1.0 : 0.4

                            Behavior on opacity { NumberAnimation { duration: 400 } }
                        }

                        OpacityMask {
                            anchors.fill: wallpaperImg
                            source: wallpaperImg
                            maskSource: maskRect
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: wrapper.ListView.isCurrentItem ? setWallpaper(imageSource) : view.currentIndex = index
                        }
                    }
                }
            }
        }
    }
}
