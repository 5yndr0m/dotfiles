import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import qs.Components
import qs.config
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: pickerWindow
    implicitWidth: 950 + 192
    implicitHeight: 200 + 96
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    visible: false
    color: "transparent"
    anchors.bottom: true

    FileView {
        id: wallpaperConfig
        path: Quickshell.env("HOME") + "/.config/quickshell/config/wallpaper.json"
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: jsonStore
            property string currentPath: ""
            onCurrentPathChanged: wallpaperConfig.writeAdapter()
        }
    }

    Process { id: swwwProcess }
    Process { id: matugenProcess }

    function forceCenter() {
        if (view.width <= 0) return;
        syncCurrentIndex();
        view.positionViewAtIndex(view.currentIndex, ListView.Center);
    }

    onVisibleChanged: {
        if (visible) {
            mainContainer.focus = true;
            view.focus = true;
            if (view.width > 0) {
                view.positionViewAtIndex(view.currentIndex, ListView.Center);
            }
        }
    }

    function setWallpaper(path) {
        let cleanPath = decodeURIComponent(path.toString().replace(/^file:\/\//, ""));
        jsonStore.currentPath = cleanPath;
        syncCurrentIndex();

        swwwProcess.command = ["swww", "img", cleanPath, "--transition-type", "grow", "--transition-fps", "60"];
        swwwProcess.running = true;

        // Trigger matugen using the auto mode defined in your config
        matugenProcess.command = ["matugen", "image", cleanPath];
        matugenProcess.running = true;

        pickerWindow.visible = false;
    }

    property bool isInitialLoad: true

    function syncCurrentIndex() {
        if (folderModel.count === 0) return;
        let folderPath = decodeURIComponent(folderModel.folder.toString().replace(/^file:\/\//, ""));
        if (folderPath.endsWith("/")) folderPath = folderPath.slice(0, -1);

        for (let i = 0; i < folderModel.count; i++) {
            let name = folderModel.get(i, "fileName");
            let fullPath = folderPath + "/" + name;

            if (fullPath === jsonStore.currentPath) {
                if (isInitialLoad) {
                    view.highlightMoveDuration = 0;
                    view.currentIndex = i;
                    view.positionViewAtIndex(i, ListView.Center);
                    view.highlightMoveDuration = 450;
                    isInitialLoad = false;
                } else {
                    view.currentIndex = i;
                }
                return;
            }
        }
    }

    Item {
        anchors.fill: parent

        // // Lift the whole container with a shadow
        // DropShadow {
        //     anchors.fill: mainContainer
        //     horizontalOffset: 0; verticalOffset: 4
        //     radius: 24; samples: 25
        //     color: ThemeAuto.shadowColor
        //     source: mainContainer
        // }

        CornerShape {
            anchors.right: mainContainer.left
            anchors.bottom: mainContainer.bottom
            color: ThemeAuto.bgContainer
            radius: 48; orientation: 3; width: 96; height: 96
        }

        CornerShape {
            anchors.left: mainContainer.right
            anchors.bottom: mainContainer.bottom
            color: ThemeAuto.bgContainer
            radius: 48; orientation: 2; width: 96; height: 96
        }

        Rectangle {
            id: mainContainer
            width: 950
            anchors.top: parent.top; anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: ThemeAuto.bgContainer
            clip: true
            topLeftRadius: 24; topRightRadius: 24
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

                readonly property real expandedWidth: 480
                readonly property real collapsedWidth: 180

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

                    Behavior on width { NumberAnimation { duration: 450; easing.type: Easing.OutQuint } }

                    Rectangle {
                        id: imageContainer
                        anchors.fill: parent
                        radius: 16
                        color: ThemeAuto.bgSurface
                        clip: true
                        border.color: wrapper.ListView.isCurrentItem ? ThemeAuto.accent : ThemeAuto.outline
                        border.width: wrapper.ListView.isCurrentItem ? 3 : 1

                        Rectangle { id: maskRect; anchors.fill: parent; radius: 16; visible: false }

                        Image {
                            id: wallpaperImg
                            anchors.fill: parent
                            anchors.margins: parent.border.width
                            source: imageSource
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 800
                            asynchronous: true; visible: false
                            opacity: wrapper.ListView.isCurrentItem ? 1.0 : 0.4
                            Behavior on opacity { NumberAnimation { duration: 400 } }
                        }

                        OpacityMask {
                            anchors.fill: wallpaperImg
                            source: wallpaperImg
                            maskSource: maskRect
                        }

                        // // Current Wallpaper Indicator (Dot)
                        // Rectangle {
                        //     anchors.bottom: parent.bottom
                        //     anchors.horizontalCenter: parent.horizontalCenter
                        //     anchors.bottomMargin: 15
                        //     z: 5
                        //     width: 12; height: 12; radius: 6
                        //     color: ThemeAuto.accent
                        //     visible: decodeURIComponent(imageSource.replace(/^file:\/\//, "")) === jsonStore.currentPath

                        //     // Add a small glow to the dot
                        //     layer.enabled: true
                        //     layer.effect: DropShadow { radius: 8; color: ThemeAuto.accent; samples: 17 }
                        // }

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
