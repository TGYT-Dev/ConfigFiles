import QtQuick
import Quickshell.Io

// Shared status source — instantiate once in shell.qml (like SystemStats),
// pass down to NetworkToggle (pill) and NetworkPopup (popup) as netStatus.
Item {
    id: root
    property string state: "none" // "warp" | "tailscale" | "none"
    property bool isBusy: false

    Process {
        id: statusProc
        command: ["bash", "-c", "$HOME/scripts/networkToggle.sh status"]
        stdout: StdioCollector {
            onStreamFinished: root.state = text.trim()
        }
    }

    Process {
        id: setProc
        property string target: ""
        command: ["bash", "-c", "$HOME/scripts/networkToggle.sh set " + target]
        stdout: StdioCollector {
            onStreamFinished: {
                root.state = text.trim()
                root.isBusy = false
            }
        }
    }

    function refresh() {
        statusProc.running = false
        statusProc.running = true
    }

    function setState(target) {
        if (root.isBusy || root.state === target) return
        root.isBusy = true
        setProc.target = target
        setProc.running = false
        setProc.running = true
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }

    Component.onCompleted: root.refresh()
}
