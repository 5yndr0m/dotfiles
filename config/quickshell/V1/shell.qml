//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick

import qs.modules.bar
import qs.modules.wallpaper
import qs.modules.notifications
import qs.modules.powermenu
import qs.modules.lockscreen
import qs.modules.launcher
import qs.modules.background
import qs.modules.controlpanel
import qs.modules.toolbar
import qs.modules.dashboard
import qs.modules.osd
import qs.utils
import "./core"

ShellRoot {
    id: shellRoot

    property int watchedBrightness: BrightnessService.brightness
    property bool pendingWifiOpen: false
    property int watchedVolume: AudioService.volume
    property bool watchedMute: AudioService.isMuted
    property bool watchedCaps: InputService.capsLock

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

    function openControlPanelWifi() {
        if (!controlPanelLoader.item) {
            pendingWifiOpen = true;
            controlPanelLoader.active = true;
        } else {
            controlPanelLoader.item.openWifi();
        }
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

    function toggleWallpaperPicker() {
        if (!wallpaperPickerLoader.active) {
            wallpaperPickerLoader.active = true;
        } else {
            if (wallpaperPickerLoader.item) {
                wallpaperPickerLoader.item.toggle();
            }
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

    LazyLoader {
        id: controlPanelLoader
        active: false
        source: "modules/controlpanel/ControlPanel.qml"

        onItemChanged: {
            if (item) {
                item.closed.connect(() => {
                    active = false;
                });
                if (shellRoot.pendingWifiOpen) {
                    item.openWifi();
                    shellRoot.pendingWifiOpen = false;
                } else {
                    item.visible = true;
                }
            }
        }
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

    Loader {
        id: wallpaperPickerLoader
        active: false
        source: "modules/wallpaper/WallpaperPicker.qml"
        onLoaded: item.visible = true
    }

    Variants {
        model: Quickshell.screens

        Bar {
            id: bar
            modelData: modelData

            onNotificationCenterRequested: notifCenter.open()
            onNetworkRequested: shellRoot.openControlPanelWifi()
        }
    }

    Variants {
        model: Quickshell.screens
        Background {
            id: background
            // If Background.qml is a PanelWindow, add: screen: modelData
            screen: modelData

            onRequestControlPanel: shellRoot.openControlPanel()
        }
    }

    PowerMenu {
        id: powerMenu
        onLockRequested: sessionLock.locked = true
    }

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

    // Background {
    //     id: background
    //     onRequestControlPanel: shellRoot.openControlPanel()
    // }

    Dashboard {
        id: dash
    }

    Notifications {
        id: notifications
    }

    NotificationCenter {
        id: notifCenter
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

    Shortcuts {
        onToggleWallpaperRequested: shellRoot.toggleWallpaperPicker()
        notifCenter: notifCenter
        sessionLock: sessionLock
        powerMenu: powerMenu
        onToggleLauncherRequested: shellRoot.toggleLauncher()

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

    Component.onCompleted: {
        console.log("Shell started in: " + Quickshell.shellDir);
        BrightnessService.refresh();
    }
}
