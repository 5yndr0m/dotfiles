import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import "../../core"

Row {
    id: trayRoot
    spacing: Theme.values.spacingS

    // This receives 'myBarWindow' from Step 2
    property var barWindow: null

    TrayMenu {
        id: contextMenu
        anchorWindow: trayRoot.barWindow // Uses the passed window
        onRequestClose: visible = false
    }

    Repeater {
        model: SystemTray.items
        delegate: IconImage {
            id: trayIcon
            source: modelData.icon
            width: Theme.values.iconSizeS
            height: Theme.values.iconSizeS

            visible: status === Image.Ready

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton

                onClicked: mouse => {
                    if (mouse.button === Qt.RightButton && modelData.menu) {

                        // Safety Check: Ensure window exists before clicking
                        if (!trayRoot.barWindow) {
                            console.error("Tray Error: barWindow property is missing! Check Bar.qml");
                            return;
                        }

                        // Map to Bar Window
                        var relativePos = trayIcon.mapToItem(trayRoot.barWindow.contentItem, 0, 0);

                        contextMenu.targetRect = Qt.rect(relativePos.x, relativePos.y, trayIcon.width, trayIcon.height);

                        contextMenu.menuHandle = modelData.menu;
                        contextMenu.visible = true;
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate();
                    } else {
                        modelData.activate();
                    }
                }
            }
        }
    }
}
