pragma Singleton
import QtQuick
import Quickshell.Io

Item {
    id: systemInfo

    property string username: "Loading..."
    property string uptime: "Loading uptime..."
    property string avatarPath: ""
    property string homePath: ""

    property bool usernameLoaded: false
    property bool homePathLoaded: false

    Process {
        id: usernameProc
        command: ["whoami"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    systemInfo.username = data.trim();
                    systemInfo.usernameLoaded = true;
                    homePathProc.running = true;
                }
            }
        }
        Component.onCompleted: running = true
    }

    Process {
        id: homePathProc
        command: ["sh", "-c", "echo $HOME"]
        stdout: SplitParser {
            onRead: data => {
                if (data) {
                    systemInfo.homePath = data.trim();
                    systemInfo.homePathLoaded = true;
                    systemInfo.avatarPath = "file://" + systemInfo.homePath + "/.config/quickshell/.pfp.jpg";
                }
            }
        }
    }

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

    Timer {
        id: uptimeTimer
        interval: 30000
        running: true
        repeat: true
        onTriggered: uptimeProc.running = true
    }

    function getFallbackAvatarPath() {
        if (usernameLoaded) {
            return "file:///var/lib/AccountsService/icons/" + username;
        }
        return "";
    }

    function getUserInitials() {
        if (usernameLoaded && username !== "Loading...") {
            return username.charAt(0).toUpperCase();
        }
        return "U";
    }

    function refresh() {
        usernameProc.running = true;
        uptimeProc.running = true;
    }
}
