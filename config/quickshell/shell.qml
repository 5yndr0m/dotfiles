//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import qs.modules.bar
import qs.modules.wallpaper
import qs.modules.notifications
import qs.modules.lockscreen
import qs.modules.launcher
import qs.modules.background
import qs.modules.controlpanel
import qs.modules.toolbar
import qs.modules.dashboard
import qs.utils

// ARCHON

ShellRoot {
    id: shellRoot

    function openControlPanel() {
        if (!controlPanelLoader.item) {
            controlPanelLoader.active = true;
        } else {
            if (!controlPanelLoader.item.visible) {
                controlPanelLoader.item.visible = true;
                controlPanelLoader.item.toggle();
            }
        }
    }

    Variants {
        model: Quickshell.screens

        Bar {
            id: bar
            modelData: modelData
            onNotificationCenterRequested: {
                notifCenter.open();
            }
        }
    }

    LazyLoader {
        id: controlPanelLoader
        active: false
        source: "modules/controlpanel/ControlPanel.qml"

        onItemChanged: {
            if (item) {
                item.closed.connect(() => {
                    active = false;
                });
                item.visible = true;
            }
        }
    }

    Background {
        id: background
        onRequestControlPanel: shellRoot.openControlPanel()
    }

    Dashboard {
        id: dash
    }

    Notifications {
        id: notifications
    }

    Loader {
        id: launcherLoader
        active: false
        source: "modules/launcher/Launcher.qml"
        onLoaded: {
            if (item)
                item.visible = true;
        }
    }

    Loader {
        id: musicPopupLoader
        active: true
        source: "modules/music/MusicPopUp.qml"
    }

    Loader {
        id: toolbarLoader
        active: true
        source: "modules/toolbar/ToolbarPopup.qml"
    }

    function toggleLauncher() {
        if (!launcherLoader.active) {
            launcherLoader.active = true;
        } else {
            if (launcherLoader.item) {
                launcherLoader.item.visible = !launcherLoader.item.visible;
            }
        }
    }

    NotificationCenter {
        id: notifCenter
    }

    LockContext {
        id: lockContext
        onUnlocked: {
            sessionLock.locked = false;
        }
    }

    WlSessionLock {
        id: sessionLock
        locked: false

        WlSessionLockSurface {
            LockSurface {
                anchors.fill: parent
                context: lockContext
            }
        }
    }

    Loader {
        id: wallpaperPickerLoader
        active: false
        source: "modules/wallpaper/WallpaperPicker.qml"

        onLoaded: {
            item.visible = true;
        }
    }

    function toggleWallpaperPicker() {
        if (!wallpaperPickerLoader.active) {
            wallpaperPickerLoader.active = true;
        } else {
            wallpaperPickerLoader.item.visible = !wallpaperPickerLoader.item.visible;
        }
    }

    Shortcuts {
        onToggleWallpaperRequested: shellRoot.toggleWallpaperPicker()
        notifCenter: notifCenter
        sessionLock: sessionLock
        onToggleLauncherRequested: shellRoot.toggleLauncher()
    }

    Component.onCompleted: {
        console.log("Shell started in: " + Quickshell.shellDir);
    }
}
