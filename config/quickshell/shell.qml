//@ pragma UseQApplication
import QtQuick
import Quickshell
import Quickshell.Wayland

import qs.modules.bar
import qs.modules.background
import qs.modules.launcher
import qs.modules.notification
import qs.modules.osd
import qs.modules.lockscreen
import qs.modules.sidebar
import qs.modules.wallpaper
import qs.utils

import "./core"

ShellRoot {
    id: shellRoot

    property int watchedBrightness: BrightnessService.brightness
    property int watchedVolume: AudioService.volume
    property bool watchedMute: AudioService.isMuted
    property bool watchedCaps: InputService.capsLock

    Shortcuts {
        picker: wallpaperPicker
        sessionLock: sessionLock

        onToggleBrightnessUpRequested: {
            BrightnessService.increase();
            brightnessOSD.show(BrightnessService.brightness);
        }

        onToggleBrightnessDownRequested: {
            BrightnessService.decrease();
            brightnessOSD.show(BrightnessService.brightness);
        }

        onToggleVolumeUpRequested: {
            AudioService.setVolume("5%+");
            volumeOSD.show(AudioService.volume, AudioService.isMuted);
        }
        onToggleVolumeDownRequested: {
            AudioService.setVolume("5%-");
            volumeOSD.show(AudioService.volume, AudioService.isMuted);
        }
        onToggleMuteRequested: {
            AudioService.toggleMute();
            // Wait slightly for mute state to update or rely on watcher
        }
    }

    function toggleSidebar() {
        if (!sidebarLoader.active) {
            sidebarLoader.active = true;
        } else if (sidebarLoader.item) {
            sidebarLoader.item.openPanel();
        }
    }

    onWatchedBrightnessChanged: {
        if (!brightnessOSD.visible) {
            brightnessOSD.show(watchedBrightness);
        }
    }

    onWatchedVolumeChanged: {
        if (!volumeOSD.visible)
            volumeOSD.show(watchedVolume, watchedMute);
    }

    onWatchedMuteChanged: {
        volumeOSD.show(watchedVolume, watchedMute);
    }

    onWatchedCapsChanged: {
        capsOSD.show(watchedCaps);
    }

    // ADD THE LOADER
    Loader {
        id: sidebarLoader
        active: false
        source: "modules/sidebar/Sidebar.qml"
        onLoaded: if (item)
            item.openPanel()
    }

    Variants {
        model: Quickshell.screens

        Bar {
            id: barRoot
            modelData: modelData
        }
    }

    Variants {
        model: Quickshell.screens

        Background {
            id: background
            modelData: modelData
            onRequestControlPanel: shellRoot.toggleSidebar()
        }
    }

    Launcher {
        id: appLauncher
    }

    WallpaperPicker {
        id: wallpaperPicker
    }

    Notification {}

    BrightnessOSD {
        id: brightnessOSD
        position: 0
    }

    VolumeOSD {
        id: volumeOSD
        position: 0
    }

    CapsLockOSD {
        id: capsOSD
    }

    LockContext {
        id: lockContext
        onUnlocked: sessionLock.locked = false
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
}
