import QtQuick
import Quickshell
import Quickshell.Services.Pam

Scope {
    id: root
    signal unlocked

    property string currentText: ""
    property bool unlockInProgress: false
    property bool showFailure: false

    onCurrentTextChanged: showFailure = false

    function tryUnlock() {
        if (currentText === "" || unlockInProgress)
            return;

        // if (currentText === "test1234") {
        //     root.unlocked();
        //     return;
        // }

        unlockInProgress = true;
        pam.start();
    }

    PamContext {
        id: pam
        config: "login"

        onPamMessage: {
            if (responseRequired) {
                respond(root.currentText);
            }
        }

        onCompleted: result => {
            unlockInProgress = false;
            if (result === PamResult.Success) {
                root.unlocked();
            } else {
                currentText = "";
                showFailure = true;
            }
        }
    }
}
