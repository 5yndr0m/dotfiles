import QtQuick
import Quickshell.Hyprland

Item {
    id: shortcuts

    property var notifCenter
    signal toggleLauncherRequested
    property var sessionLock
    signal toggleWallpaperRequested

    GlobalShortcut {
        name: "toggleNotificationCenter"
        description: "Toggles the persistent notification history center"
        onPressed: shortcuts.notifCenter.isOpen = !shortcuts.notifCenter.isOpen
    }

    GlobalShortcut {
        name: "toggleLauncher"
        onPressed: shortcuts.toggleLauncherRequested()
    }

    GlobalShortcut {
        name: "lockSession"
        onPressed: shortcuts.sessionLock.locked = true
    }

    GlobalShortcut {
        name: "toggleWallpaperPicker"
        description: "Toggles the Quickshell wallpaper selection window"
        onPressed: shortcuts.toggleWallpaperRequested()
    }
}
