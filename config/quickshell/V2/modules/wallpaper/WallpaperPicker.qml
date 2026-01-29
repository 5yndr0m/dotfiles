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

    // SCALED DIMENSIONS
    implicitWidth: 720 + (Theme.settings.spacingXL * 4)
    implicitHeight: 180 + (Theme.settings.spacingXL * 2)

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    visible: false
    color: "transparent"
    anchors.bottom: true

    function toggle() {
        visible = !visible;
        if (visible) {
            Qt.callLater(() => mainContainer.forceActiveFocus());
        }
    }

    FileView {
        id: wallpaperConfig
        path: Quickshell.env("HOME") + "/.config/quickshell/V2/config/wallpaper.json"

        JsonAdapter {
            id: jsonStore
            property string currentPath: ""
            onCurrentPathChanged: wallpaperConfig.writeAdapter()
        }
    }

    Process {
        id: runner
    }

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
        if (folderModel.count === 0)
            return;
        let folderPath = decodeURIComponent(folderModel.folder.toString().replace(/^file:\/\//, ""));
        if (folderPath.endsWith("/"))
            folderPath = folderPath.slice(0, -1);

        for (let i = 0; i < folderModel.count; i++) {
            let name = folderModel.get(i, "fileName");
            let fullPath = folderPath + "/" + name;
            if (fullPath === jsonStore.currentPath) {
                view.currentIndex = i; // Adjusted to standard 0-indexing
                return;
            }
        }
    }

    function forceCenter() {
        if (view.width <= 0)
            return;
        syncCurrentIndex();
        view.positionViewAtIndex(view.currentIndex, ListView.Center);
    }

    Item {
        anchors.fill: parent

        CornerShape {
            anchors.right: mainContainer.left
            anchors.bottom: mainContainer.bottom
            color: Colors.colors.surface_container
            radius: Theme.settings.roundXL
            orientation: 3
            width: Theme.settings.roundXL * 2
            height: Theme.settings.roundXL * 2
        }

        CornerShape {
            anchors.left: mainContainer.right
            anchors.bottom: mainContainer.bottom
            color: Colors.colors.surface_container
            radius: Theme.settings.roundXL
            orientation: 2
            width: Theme.settings.roundXL * 2
            height: Theme.settings.roundXL * 2
        }

        Rectangle {
            id: mainContainer
            width: 660 // SCALED
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colors.colors.surface_container
            clip: true
            topLeftRadius: Theme.settings.roundXL
            topRightRadius: Theme.settings.roundXL
            focus: true

            Keys.onLeftPressed: view.decrementCurrentIndex()
            Keys.onRightPressed: view.incrementCurrentIndex()
            Keys.onReturnPressed: if (view.currentItem)
                setWallpaper(view.currentItem.imageSource)
            Keys.onEscapePressed: pickerWindow.visible = false

            ListView {
                id: view
                anchors.fill: parent
                anchors.margins: Theme.settings.spacingS
                orientation: ListView.Horizontal
                spacing: Theme.settings.spacingXS
                clip: true
                highlightMoveDuration: 450
                snapMode: ListView.SnapToItem

                // WRAP DISABLED
                keyNavigationWraps: false

                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: (width / 2) - (expandedWidth / 2)
                preferredHighlightEnd: (width / 2) + (expandedWidth / 2)

                // SCALED ITEM SIZES
                readonly property real expandedWidth: 340
                readonly property real collapsedWidth: 144

                model: FolderListModel {
                    id: folderModel
                    folder: "file://" + Quickshell.env("HOME") + "/Pictures/wallpapers"
                    nameFilters: ["*.jpg", "*.png", "*.webp", "*.jpeg"]
                    onStatusChanged: if (status === FolderListModel.Ready)
                        Qt.callLater(forceCenter)
                }

                delegate: Item {
                    id: wrapper
                    readonly property string imageSource: folderModel.folder + "/" + fileName

                    // Boundary-aware logic for neighbors
                    readonly property bool isPrevious: index === view.currentIndex - 1
                    readonly property bool isNext: index === view.currentIndex + 1

                    height: view.height
                    width: ListView.isCurrentItem ? view.expandedWidth : view.collapsedWidth
                    clip: true
                    z: ListView.isCurrentItem ? 10 : 1

                    Behavior on width {
                        NumberAnimation {
                            duration: 450
                            easing.type: Easing.OutQuint
                        }
                    }

                    Rectangle {
                        id: imageContainer
                        anchors.fill: parent
                        radius: Theme.settings.roundM
                        color: Colors.colors.surface
                        clip: true
                        border.color: wrapper.ListView.isCurrentItem ? Colors.colors.primary : Colors.colors.outline
                        border.width: wrapper.ListView.isCurrentItem ? 3 : 0

                        // Your logic: Previous item gets XL left corners, Next gets XL right corners
                        topLeftRadius: wrapper.isPrevious ? Theme.settings.roundXL : Theme.settings.roundM
                        bottomLeftRadius: wrapper.isPrevious ? Theme.settings.roundXL : Theme.settings.roundM
                        topRightRadius: wrapper.isNext ? Theme.settings.roundXL : Theme.settings.roundM
                        bottomRightRadius: wrapper.isNext ? Theme.settings.roundXL : Theme.settings.roundM

                        Rectangle {
                            id: maskRect
                            anchors.fill: parent
                            radius: Theme.settings.roundM
                            visible: false
                            topLeftRadius: parent.topLeftRadius
                            bottomLeftRadius: parent.bottomLeftRadius
                            topRightRadius: parent.topRightRadius
                            bottomRightRadius: parent.bottomRightRadius
                        }

                        Image {
                            id: wallpaperImg
                            anchors.fill: parent
                            anchors.margins: parent.border.width
                            source: imageSource
                            fillMode: Image.PreserveAspectCrop
                            sourceSize.width: 400 // SCALED for clarity
                            asynchronous: true
                            visible: false
                            opacity: wrapper.ListView.isCurrentItem ? 1.0 : 0.4

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 400
                                }
                            }
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
