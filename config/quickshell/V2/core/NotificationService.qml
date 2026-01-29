pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

QtObject {
    id: root

    property bool dndActive: false

    property NotificationServer server: NotificationServer {
        id: notificationServer

        keepOnReload: false
        imageSupported: true
        actionsSupported: true
        actionIconsSupported: true
        bodyMarkupSupported: true
        bodySupported: true
        persistenceSupported: true
        inlineReplySupported: true
        bodyHyperlinksSupported: true
        bodyImagesSupported: true

        onNotification: function (notification) {
            try {
                notification.tracked = true;

                notification.closed.connect(function () {
                    root.removeNotification(notification);
                });

                root.addToHistory(notification);

                if (!root.dndActive) {
                    root.addNotification(notification);
                } else {
                    notification.dismiss();
                }
            } catch (e) {
                console.error("NotificationService: Error processing notification:", e);
            }
        }
    }

    property ListModel notificationModel: ListModel {}
    property ListModel historyModel: ListModel {}

    property int maxHistory: 100
    property int maxVisible: 5
    property string historyFile: Quickshell.env("HOME") + "/.config/quickshell/config/notifications.json"

    property FileView historyFileView: FileView {
        id: historyFileView
        path: historyFile
        objectName: "notificationHistoryFileView"
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        Component.onCompleted: reload()
        onLoaded: loadFromHistory()

        onLoadFailed: function (error) {
            if (error.toString().includes("No such file") || error === 2)
                writeAdapter();
        }

        onSaveFailed: function (error) {
            console.error("NotificationService: History file save failed:", error);
        }

        JsonAdapter {
            id: historyAdapter
            property var history: []
            property double timestamp: 0
        }
    }

    property Timer hideTimer: Timer {
        interval: 8000
        repeat: true
        running: notificationModel.count > 0
        onTriggered: {
            if (notificationModel.count > 0) {
                // Get the oldest notification (last in the list)
                let idx = notificationModel.count - 1;
                let item = notificationModel.get(idx);
                if (item && item.rawNotification) {
                    root.animateAndRemove(item.rawNotification, idx);
                }
            }
        }
    }

    signal animateAndRemove(var notification, int index)

    function addNotification(notification) {
        for (let i = 0; i < notificationModel.count; i++) {
            if (notificationModel.get(i).rawNotification === notification)
                return;
        }

        notificationModel.insert(0, {
            "rawNotification": notification,
            "summary": notification.summary,
            "body": notification.body,
            "appName": notification.appName,
            "urgency": notification.urgency,
            "timestamp": new Date()
        });

        if (notificationModel.count > maxVisible) {
            notificationModel.remove(notificationModel.count - 1);
        }
    }

    function addToHistory(notification) {
        historyModel.insert(0, {
            "summary": notification.summary,
            "body": notification.body,
            "appName": notification.appName,
            "urgency": notification.urgency,
            "timestamp": new Date()
        });
        if (historyModel.count > maxHistory)
            historyModel.remove(historyModel.count - 1);
        saveHistory();
    }

    function clearHistory() {
        try {
            historyModel.clear();
            saveHistory();
        } catch (e) {
            console.error("NotificationService: Error clearing history:", e);
        }
    }

    function saveHistory() {
        var arr = [];
        for (var i = 0; i < historyModel.count; i++) {
            const n = historyModel.get(i);
            arr.push({
                "summary": n.summary,
                "body": n.body,
                "appName": n.appName,
                "urgency": n.urgency,
                "timestamp": (n.timestamp instanceof Date ? n.timestamp.getTime() : n.timestamp)
            });
        }
        historyAdapter.history = arr;
        historyAdapter.timestamp = Date.now();
        Qt.callLater(() => historyFileView.writeAdapter());
    }

    function loadFromHistory() {
        historyModel.clear();
        const items = historyAdapter.history || [];
        items.forEach(it => {
            historyModel.append({
                "summary": it.summary || "",
                "body": it.body || "",
                "appName": it.appName || "",
                "urgency": it.urgency,
                "timestamp": it.timestamp ? new Date(it.timestamp) : new Date()
            });
        });
    }

    function forceRemoveNotification(notification) {
        for (var i = 0; i < notificationModel.count; i++) {
            if (notificationModel.get(i).rawNotification === notification) {
                notificationModel.remove(i);
                break;
            }
        }
    }

    function removeNotification(notification) {
        for (var i = 0; i < notificationModel.count; i++) {
            if (notificationModel.get(i).rawNotification === notification) {
                animateAndRemove(notification, i);
                break;
            }
        }
    }

    function formatTimestamp(timestamp) {
        if (!timestamp)
            return "";
        const diff = new Date() - timestamp;
        if (diff < 60000)
            return "now";
        if (diff < 3600000)
            return Math.floor(diff / 60000) + "m ago";
        if (diff < 86400000)
            return Math.floor(diff / 3600000) + "h ago";
        return Math.floor(diff / 86400000) + "d ago";
    }

    function removeHistoryAt(index) {
        if (index >= 0 && index < historyModel.count) {
            historyModel.remove(index);
            saveHistory();
        }
    }
}
