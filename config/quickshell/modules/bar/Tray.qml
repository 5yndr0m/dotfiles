import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../core"

Row {
    id: trayRoot
    spacing: Theme.values.spacingS

    Repeater {
        model: SystemTray.items
        delegate: IconImage {
            id: trayIcon
            source: modelData.icon
            width: Theme.values.iconSizeS
            height: Theme.values.iconSizeS

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton && modelData.menu) {
                        // USE the menuHandle we passed down
                        // menuHandle.trayItem = modelData;

                        // var rect = trayIcon.mapToGlobal(0, 0);
                        // menuHandle.anchor.rect = Qt.rect(rect.x, rect.y, trayIcon.width, trayIcon.height);

                        // menuHandle.visible = true;
                    } else {
                        modelData.activate();
                    }
                }
            }
        }
    }
}
