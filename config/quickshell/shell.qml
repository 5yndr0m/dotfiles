//@ pragma UseQApplication
import Quickshell
import QtQuick
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs.modules.wallpaper
import qs.modules.lockscreen
import qs.modules.launcher
import qs.modules.notifications
import qs.modules.bar
import qs.modules.controlpanel
import qs.modules.background
import qs.config

ShellRoot {
    id: root

    FileView {
            path: Quickshell.env("HOME") + "/.config/quickshell/config/ThemeAuto.qml"
            watchChanges: true

            onFileChanged: {
                console.log("Theme file change detected...")
                // Delay reload by 100ms to ensure Matugen has finished writing the file
                reloadTimer.restart()
            }
    }

    Timer {
            id: reloadTimer
            interval: 100
            onTriggered: {
                console.log("Reloading configuration now.")
                Quickshell.reload()
            }
    }

    Background {
        id: bg
    }

    WallpaperPicker {
        id: wallpaperPicker
    }

    Notifications {
        id: notifications
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

    AppLauncher {
        id: appLauncher
        visible: false
    }

    GlobalShortcut {
        name: "toggleNotificationCenter"
        description: "Toggles the persistent notification history center"

        onPressed: {
            notifCenter.isOpen = !notifCenter.isOpen;
        }
    }

    GlobalShortcut {
        name: "toggleLauncher"
        onPressed: appLauncher.visible = !appLauncher.visible
    }

    GlobalShortcut {
        name: "lockSession"
        onPressed: {
            sessionLock.locked = true;
        }
    }

    GlobalShortcut {
        name: "toggleWallpaperPicker"
        description: "Toggles the Quickshell wallpaper selection window"

        onPressed: {
            wallpaperPicker.visible = !wallpaperPicker.visible;
        }
    }

    ControlPanel {
        id: controlPanel
    }

    Bar {
        id: bar
        controlPanel: controlPanel
    }
}
