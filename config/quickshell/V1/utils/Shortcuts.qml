import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: shortcuts

    property var notifCenter
    property var sessionLock
    property var powerMenu

    // --- Signals ---
    signal toggleLauncherRequested
    signal toggleWallpaperRequested

    // Brightness Signals
    signal toggleBrightnessUpRequested
    signal toggleBrightnessDownRequested

    // Volume Signals (These were missing!)
    signal toggleVolumeUpRequested
    signal toggleVolumeDownRequested
    signal toggleMuteRequested

    // --- Existing Shortcuts ---
    GlobalShortcut {
        name: "toggleNotificationCenter"
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
        onPressed: shortcuts.toggleWallpaperRequested()
    }

    // --- Brightness Shortcuts ---
    GlobalShortcut {
        name: "brightnessUp"
        // key: "XF86MonBrightnessUp" // Uncomment if Quickshell doesn't auto-detect
        onPressed: shortcuts.toggleBrightnessUpRequested()
    }

    GlobalShortcut {
        name: "brightnessDown"
        // key: "XF86MonBrightnessDown"
        onPressed: shortcuts.toggleBrightnessDownRequested()
    }

    // --- Volume Shortcuts (New) ---
    GlobalShortcut {
        name: "volumeUp"
        // key: "XF86AudioRaiseVolume"
        onPressed: shortcuts.toggleVolumeUpRequested()
    }

    GlobalShortcut {
        name: "volumeDown"
        // key: "XF86AudioLowerVolume"
        onPressed: shortcuts.toggleVolumeDownRequested()
    }

    GlobalShortcut {
        name: "mute"
        // key: "XF86AudioMute"
        onPressed: shortcuts.toggleMuteRequested()
    }

    GlobalShortcut {
        name: "powerMenu"
        // key: "super + x" // Or bind this in Hyprland config
        onPressed: shortcuts.powerMenu.toggle()
    }
}
