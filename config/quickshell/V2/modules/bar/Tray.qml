import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../core"

Row {
    id: trayRoot
    spacing: Theme.settings.spacingS

    property var barWindow: null

    TrayMenu {
        id: contextMenu
        anchorWindow: trayRoot.barWindow
        onRequestClose: visible = false
    }

    Repeater {
        model: SystemTray.items
        delegate: IconImage {
            id: trayIcon
            source: modelData.icon
            width: Theme.settings.iconSizeS
            height: Theme.settings.iconSizeS
            visible: status === Image.Ready

            Timer {
                id: hoverTimer
                interval: 300 // Open after 300ms of hovering
                onTriggered: {
                    if (!trayRoot.barWindow)
                        return;

                    var relativePos = trayIcon.mapToItem(trayRoot.barWindow.contentItem, 0, 0);
                    contextMenu.targetRect = Qt.rect(relativePos.x, relativePos.y, trayIcon.width, trayIcon.height);

                    contextMenu.menuHandle = modelData.menu;
                    contextMenu.visible = true;
                }
            }

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                acceptedButtons: Qt.LeftButton | Qt.RightButton

                onEntered: {
                    if (modelData.menu) {
                        contextMenu.closeTimer.stop();
                        hoverTimer.start();
                    }
                }

                onExited: {
                    hoverTimer.stop();
                    if (contextMenu.visible) {
                        contextMenu.closeTimer.start();
                    }
                }

                onClicked: mouse => {
                    hoverTimer.stop();
                    contextMenu.closeTimer.stop();
                    if (mouse.button === Qt.RightButton) {
                        contextMenu.visible = !contextMenu.visible;
                    } else {
                        contextMenu.visible = false;
                        modelData.activate();
                    }
                }
            }
        }
    }
}
