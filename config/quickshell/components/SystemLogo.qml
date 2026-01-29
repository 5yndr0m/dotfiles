// SystemLogoColored.qml
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "../core"

IconImage {
    id: root

    property color color: Colors.colors.primary

    width: Theme.settings.iconSizeM
    height: Theme.settings.iconSizeM

    smooth: true
    asynchronous: true
    layer.enabled: true
    layer.effect: MultiEffect {
        colorization: 1
        colorizationColor: root.color
        brightness: 0.5
    }

    Process {
        running: true
        command: ["sh", "-c", ". /etc/os-release && echo $LOGO"]
        stdout: StdioCollector {
            onStreamFinished: () => {
                const path = Quickshell.iconPath(this.text.trim());
                if (path) {
                    root.source = path;
                } else {
                    // Fallback in case $LOGO is empty or icon not found
                    root.source = Quickshell.iconPath("archlinux-logo");
                }
            }
        }
    }
}
