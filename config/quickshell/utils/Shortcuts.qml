import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    id: shortcuts

    required property var picker
    property var sessionLock

    signal toggleBrightnessUpRequested
    signal toggleBrightnessDownRequested
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

    GlobalShortcut {
        name: "brightnessUp"
        onPressed: shortcuts.toggleBrightnessUpRequested()
    }

    GlobalShortcut {
        name: "brightnessDown"
        onPressed: shortcuts.toggleBrightnessDownRequested()
    }

    GlobalShortcut {
        name: "volumeUp"
        onPressed: shortcuts.toggleVolumeUpRequested()
    }

    GlobalShortcut {
        name: "volumeDown"
        onPressed: shortcuts.toggleVolumeDownRequested()
    }

    GlobalShortcut {
        name: "mute"
        onPressed: shortcuts.toggleMuteRequested()
    }
}
