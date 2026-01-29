import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: shortcuts

    // 1. Add this required property
    required property var picker
    property var sessionLock

    // Brightness Signals
    signal toggleBrightnessUpRequested
    signal toggleBrightnessDownRequested

    // Volume Signals (These were missing!)
    signal toggleVolumeUpRequested
    signal toggleVolumeDownRequested
    signal toggleMuteRequested

    GlobalShortcut {
        name: "Launcher"
        onPressed: appLauncher.toggle()
    }

    GlobalShortcut {
        name: "WallpaperPicker"
        description: "Toggle the wallpaper selector"
        onPressed: {
            // 2. Use the property we just defined
            if (shortcuts.picker) {
                shortcuts.picker.toggle();
            }
        }
    }

    GlobalShortcut {
        name: "lockSession"
        onPressed: shortcuts.sessionLock.locked = true
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
}
