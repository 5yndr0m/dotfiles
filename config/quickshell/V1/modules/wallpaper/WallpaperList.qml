import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs.components
import "../../core"

FocusScope {
    id: root

    // --- Interface with Parent ---
    property string activeConfigPath: ""
    signal wallpaperSelected(string path)
    signal closeRequested
    signal closeFinished

    anchors.fill: parent

    // --- Animations ---

    // 1. Entrance Animation (Runs immediately on load)
    ParallelAnimation {
        id: openAnim
        running: true

        // Screen Copy: Shrink from full screen size to preview size
        NumberAnimation {
            target: scScale
            property: "xScale"
            from: root.width / 800
            to: 1.0
            duration: 500
            easing.type: Easing.OutQuint
        }
        NumberAnimation {
            target: scScale
            property: "yScale"
            from: root.height / 450
            to: 1.0
            duration: 500
            easing.type: Easing.OutQuint
        }
        // Move it down from the center of the screen to its final position
        NumberAnimation {
            target: scTrans
            property: "y"
            from: -200
            to: 0 // Approx adjustment to center it initially
            duration: 500
            easing.type: Easing.OutQuint
        }

        // List: Slide up from bottom
        NumberAnimation {
            target: listTrans
            property: "y"
            from: 300
            to: 0
            duration: 450
            easing.type: Easing.OutQuint
        }
        NumberAnimation {
            target: mainContainer
            property: "opacity"
            from: 0
            to: 1
            duration: 400
        }
    }

    // 2. Exit Animation (Called by parent)
    ParallelAnimation {
        id: closeAnim
        onFinished: root.closeFinished() // Tell parent to hide window now

        // Screen Copy: Grow back to full screen
        NumberAnimation {
            target: scScale
            property: "xScale"
            to: root.width / 800
            duration: 350
            easing.type: Easing.InQuint
        }
        NumberAnimation {
            target: scScale
            property: "yScale"
            to: root.height / 450
            duration: 350
            easing.type: Easing.InQuint
        }
        NumberAnimation {
            target: scTrans
            property: "y"
            to: -200
            duration: 350
            easing.type: Easing.InQuint
        }
        NumberAnimation {
            target: screenCopyContainer
            property: "opacity"
            to: 0 // Fade it out slightly as it grows so it doesn't look pixelated
            duration: 350
        }

        // List: Slide down
        NumberAnimation {
            target: listTrans
            property: "y"
            to: 300
            duration: 300
            easing.type: Easing.InQuint
        }
        NumberAnimation {
            target: mainContainer
            property: "opacity"
            to: 0
            duration: 300
        }
    }

    // Function for parent to trigger
    function startCloseAnimation() {
        if (!closeAnim.running)
            closeAnim.start();
    }

    // --- Helper Logic ---
    function syncCurrentIndex() {
        if (folderModel.count === 0)
            return;

        let folderPath = decodeURIComponent(folderModel.folder.toString().replace(/^file:\/\//, ""));
        if (folderPath.endsWith("/"))
            folderPath = folderPath.slice(0, -1);

        for (let i = 0; i < folderModel.count; i++) {
            let name = folderModel.get(i, "fileName");
            let fullPath = folderPath + "/" + name;

            if (fullPath === activeConfigPath) {
                view.currentIndex = i + 1;
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

    // --- Visual Components ---

    // Screen Copy
    Item {
        id: screenCopyContainer
        width: 800
        height: 450
        anchors.bottom: mainContainer.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 20

        transform: [
            Scale {
                id: scScale
                origin.x: 400
                origin.y: 225
            },
            Translate {
                id: scTrans
            }
        ]

        Item {
            id: contentItem
            anchors.fill: parent
            visible: false

            ScreencopyView {
                anchors.fill: parent
                captureSource: Quickshell.screens?.[0]
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.4
            }
        }

        Rectangle {
            id: containerMask
            anchors.fill: parent
            radius: 16
            visible: false
        }

        OpacityMask {
            anchors.fill: parent
            source: contentItem
            maskSource: containerMask
        }
    }

    // Corner Shapes
    CornerShape {
        anchors.right: mainContainer.left
        anchors.bottom: mainContainer.bottom
        color: Colors.colors.surface_container
        radius: 24
        orientation: 3
        width: 96
        height: 96
        transform: Translate {
            y: listTrans.y
        }
    }

    CornerShape {
        anchors.left: mainContainer.right
        anchors.bottom: mainContainer.bottom
        color: Colors.colors.surface_container
        radius: 24
        orientation: 2
        width: 96
        height: 96
        transform: Translate {
            y: listTrans.y
        }
    }

    // Main List Container
    Rectangle {
        id: mainContainer
        width: 650
        anchors.bottom: parent.bottom
        implicitWidth: 800 + (Theme.values.spacingXL * 8)
        implicitHeight: 180 + (Theme.values.spacingXL * 4)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Colors.colors.surface_container
        clip: true
        topLeftRadius: Theme.values.roundL
        topRightRadius: Theme.values.roundL
        focus: true

        transform: Translate {
            id: listTrans
        }

        Keys.onLeftPressed: view.decrementCurrentIndex()
        Keys.onRightPressed: view.incrementCurrentIndex()
        Keys.onReturnPressed: if (view.currentItem)
            root.wallpaperSelected(view.currentItem.imageSource)
        Keys.onEscapePressed: root.closeRequested()

        ListView {
            id: view
            anchors.fill: parent
            anchors.margins: 10
            orientation: ListView.Horizontal
            spacing: 5
            clip: true
            highlightMoveDuration: 450
            snapMode: ListView.SnapToItem
            keyNavigationWraps: true
            highlightRangeMode: ListView.StrictlyEnforceRange
            preferredHighlightBegin: (width / 2) - (expandedWidth / 2)
            preferredHighlightEnd: (width / 2) + (expandedWidth / 2)

            readonly property real expandedWidth: 350
            readonly property real collapsedWidth: 130

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
                    anchors.fill: parent
                    radius: 16
                    color: Colors.colors.surface
                    clip: true
                    border.color: wrapper.ListView.isCurrentItem ? Colors.colors.primary : Colors.colors.outline
                    border.width: wrapper.ListView.isCurrentItem ? 3 : 1

                    // Mask for the rounded corners of the image inside
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
                        sourceSize.width: 256
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
                        onClicked: wrapper.ListView.isCurrentItem ? root.wallpaperSelected(imageSource) : view.currentIndex = index
                    }
                }
            }
        }
    }
}
