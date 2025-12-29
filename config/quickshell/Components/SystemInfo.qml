pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: systemInfo

    // Properties exposed to other components
    property string username: "Loading..."
    property string uptime: "Loading uptime..."
    property string avatarPath: ""
    property string homePath: ""

    // Internal state tracking
    property bool usernameLoaded: false
    property bool homePathLoaded: false

    // Get system username
    Process {
        id: usernameProc
        command: ["whoami"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    systemInfo.username = data.trim();
                    systemInfo.usernameLoaded = true;
                    // Start home path process after username is loaded
                    homePathProc.running = true;
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Get HOME directory path
    Process {
        id: homePathProc
        command: ["sh", "-c", "echo $HOME"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    systemInfo.homePath = data.trim();
                    systemInfo.homePathLoaded = true;
                    // Set avatar path once we have home directory
                    systemInfo.avatarPath = "file://" + systemInfo.homePath + "/.config/quickshell/.pfp.jpg";
                }
            }
        }
    }

    // Get system uptime
    Process {
        id: uptimeProc
        command: ["sh", "-c", "uptime -p"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    systemInfo.uptime = data.trim().replace("up ", "");
                }
            }
        }
        Component.onCompleted: running = true
    }

    // Update uptime every 30 seconds
    Timer {
        id: uptimeTimer
        interval: 30000
        running: true
        repeat: true
        onTriggered: uptimeProc.running = true
    }

    // Helper function to get fallback avatar path
    function getFallbackAvatarPath() {
        if (usernameLoaded) {
            return "file:///var/lib/AccountsService/icons/" + username;
        }
        return "";
    }

    // Helper function to get user initials
    function getUserInitials() {
        if (usernameLoaded && username !== "Loading...") {
            return username.charAt(0).toUpperCase();
        }
        return "U";
    }

    // Refresh all system info (useful for debugging or manual refresh)
    function refresh() {
        usernameProc.running = true;
        uptimeProc.running = true;
    }
}
