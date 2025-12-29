pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

QtObject {
    id: root

    // Notification server instance
    property NotificationServer server: NotificationServer {
        id: notificationServer

        // Server capabilities
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

        // Signal when notification is received
        onNotification: function (notification) {
            try {
                // Track the notification
                notification.tracked = true;

                // Connect to closed signal for cleanup
                notification.closed.connect(function () {
                    root.removeNotification(notification);
                });

                // Add to our model
                root.addNotification(notification);
                // Also add to history
                root.addToHistory(notification);
            } catch (e) {
                console.error("NotificationService: Error processing notification:", e);
            }
        }
    }

    // List model to hold notifications
    property ListModel notificationModel: ListModel {}

    // Persistent history of notifications (most recent first)
    property ListModel historyModel: ListModel {}
    property int maxHistory: 100

    // Cached history file path
    property string historyFile: "/home/syndrom/.config/quickshell/config/notifications.json"

    // Persisted storage for history
    property FileView historyFileView: FileView {
        id: historyFileView
        objectName: "notificationHistoryFileView"
        path: historyFile
        watchChanges: true

        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        Component.onCompleted: reload()
        onLoaded: loadFromHistory()

        onLoadFailed: function (error) {
            // Create file on first use
            if (error.toString().includes("No such file") || error === 2) {
                writeAdapter();
            }
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

    // Maximum visible notifications
    property int maxVisible: 5

    // Auto-hide timer
    property Timer hideTimer: Timer {
        interval: 8000 // 8 seconds - longer display time
        repeat: true
        running: notificationModel.count > 0

        onTriggered: {
            if (notificationModel.count === 0) {
                return;
            }

            // Remove the oldest notification (last in the list)
            let oldestNotification = notificationModel.get(notificationModel.count - 1).rawNotification;
            if (oldestNotification) {
                // Trigger animation signal instead of direct dismiss
                animateAndRemove(oldestNotification, notificationModel.count - 1);
            }
        }
    }

    // Function to add notification to model
    function addNotification(notification) {
        try {
            notificationModel.insert(0, {
                "rawNotification": notification,
                "summary": notification.summary,
                "body": notification.body,
                "appName": notification.appName,
                "urgency": notification.urgency,
                "timestamp": new Date()
            });

            // Remove oldest notifications if we exceed maxVisible
            while (notificationModel.count > maxVisible) {
                let oldestNotification = notificationModel.get(notificationModel.count - 1).rawNotification;
                if (oldestNotification) {
                    oldestNotification.dismiss();
                }
                notificationModel.remove(notificationModel.count - 1);
            }
        } catch (e) {
            console.error("NotificationService: Error in addNotification:", e);
        }
    }

    // Add a simplified copy into persistent history
    function addToHistory(notification) {
        try {
            historyModel.insert(0, {
                "summary": notification.summary,
                "body": notification.body,
                "appName": notification.appName,
                "urgency": notification.urgency,
                "timestamp": new Date()
            });

            while (historyModel.count > maxHistory) {
                historyModel.remove(historyModel.count - 1);
            }

            saveHistory();
        } catch (e) {
            console.error("NotificationService: Error in addToHistory:", e);
        }
    }

    function clearHistory() {
        try {
            historyModel.clear();
            saveHistory();
        } catch (e) {
            console.error("NotificationService: Error clearing history:", e);
        }
    }

    function loadFromHistory() {
        // Populate in-memory model from adapter
        try {
            historyModel.clear();
            const items = historyAdapter.history || [];

            for (var i = 0; i < items.length; i++) {
                const it = items[i];
                historyModel.append({
                    "summary": it.summary || "",
                    "body": it.body || "",
                    "appName": it.appName || "",
                    "urgency": it.urgency,
                    "timestamp": it.timestamp ? new Date(it.timestamp) : new Date()
                });
            }
        } catch (e) {
            console.error("NotificationService: Failed to load history:", e);
        }
    }

    function saveHistory() {
        try {
            // Serialize model back to adapter
            var arr = [];
            for (var i = 0; i < historyModel.count; i++) {
                const n = historyModel.get(i);
                arr.push({
                    "summary": n.summary,
                    "body": n.body,
                    "appName": n.appName,
                    "urgency": n.urgency,
                    "timestamp": (n.timestamp instanceof Date) ? n.timestamp.getTime() : n.timestamp
                });
            }

            historyAdapter.history = arr;
            historyAdapter.timestamp = Date.now();

            Qt.callLater(function () {
                historyFileView.writeAdapter();
            });
        } catch (e) {
            console.error("NotificationService: Failed to save history:", e);
        }
    }

    // Signal to trigger animation before removal
    signal animateAndRemove(var notification, int index)

    // Function to remove notification from model
    function removeNotification(notification) {
        try {
            for (var i = 0; i < notificationModel.count; i++) {
                if (notificationModel.get(i).rawNotification === notification) {
                    // Emit signal to trigger animation first
                    animateAndRemove(notification, i);
                    break;
                }
            }
        } catch (e) {
            console.error("NotificationService: Error in removeNotification:", e);
        }
    }

    // Function to actually remove notification after animation
    function forceRemoveNotification(notification) {
        try {
            for (var i = 0; i < notificationModel.count; i++) {
                if (notificationModel.get(i).rawNotification === notification) {
                    notificationModel.remove(i);
                    break;
                }
            }
        } catch (e) {
            console.error("NotificationService: Error in forceRemoveNotification:", e);
        }
    }

    // Function to format timestamp
    function formatTimestamp(timestamp) {
        if (!timestamp)
            return "";

        try {
            const now = new Date();
            const diff = now - timestamp;

            // Less than 1 minute
            if (diff < 60000) {
                return "now";
            } // Less than 1 hour
            else if (diff < 3600000) {
                const minutes = Math.floor(diff / 60000);
                return `${minutes}m ago`;
            } // Less than 24 hours
            else if (diff < 86400000) {
                const hours = Math.floor(diff / 3600000);
                return `${hours}h ago`;
            } else {
                const days = Math.floor(diff / 86400000);
                return `${days}d ago`;
            }
        } catch (e) {
            console.error("NotificationService: Error formatting timestamp:", e);
            return "unknown";
        }
    }
}
