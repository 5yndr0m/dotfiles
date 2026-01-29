import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Qt5Compat.GraphicalEffects
import qs.components
import "../../core"

PanelWindow {
    id: pickerWindow

    anchors.top: true
    anchors.bottom: true
    anchors.right: true
    anchors.left: true

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    visible: false
    color: "transparent"

    // --- Function for Shell.qml to call ---
    function toggle() {
        if (visible) {
            if (viewLoader.item) {
                viewLoader.item.startCloseAnimation();
            } else {
                visible = false;
            }
        } else {
            visible = true;
            if (viewLoader.item)
                viewLoader.item.forceActiveFocus();
        }
    }

    // --- Configuration & Logic ---
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

    function applyWallpaper(path) {
        let cleanPath = decodeURIComponent(path.toString().replace(/^file:\/\//, ""));
        jsonStore.currentPath = cleanPath;

        runner.command = ["swww", "img", cleanPath, "--transition-type", "grow"];
        runner.startDetached();

        runner.command = ["matugen", "image", cleanPath];
        runner.startDetached();

        if (viewLoader.item) {
            viewLoader.item.startCloseAnimation();
        }
    }

    // --- Background Layer ---
    Rectangle {
        id: backgroundRectangle
        z: -1
        anchors.fill: parent
        color: "transparent"

        opacity: pickerWindow.visible ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: 400
            }
        }

        Image {
            id: bgSource
            anchors.fill: parent
            source: jsonStore.currentPath
            fillMode: Image.PreserveAspectCrop
            visible: true
            asynchronous: true
            sourceSize.width: 64
        }

        FastBlur {
            id: blurredBg
            anchors.fill: bgSource
            source: bgSource
            radius: 64
            visible: true
        }
    }

    // --- Heavy UI Loader ---
    Loader {
        id: viewLoader
        anchors.fill: parent

        // FIX: This binding automatically handles loading/unloading.
        // Do NOT set active = false manually in onVisibleChanged, or this stops working.
        active: pickerWindow.visible

        asynchronous: true
        source: "WallpaperList.qml"

        onLoaded: {
            item.activeConfigPath = jsonStore.currentPath;

            item.wallpaperSelected.connect(applyWallpaper);

            item.closeRequested.connect(function () {
                item.startCloseAnimation();
            });

            item.closeFinished.connect(function () {
                pickerWindow.visible = false;
            });

            item.forceActiveFocus();
        }
    }
}
