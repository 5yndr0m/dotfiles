pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    // For standard commands where you might want to read output
    function run(commandList) {
        const proc = Quickshell.createProcess(commandList);
        proc.running = true;
        return proc;
    }

    // For launching apps (won't die when Quickshell reloads)
    function detach(commandList) {
        Quickshell.execDetached(commandList);
    }
}
