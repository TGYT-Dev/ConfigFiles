import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// Drop this in shell.qml's leftSide Row (or wherever you want it).
// Exposes: voicePill (Rectangle) + voiceWidget (VoicePopup)
//
// In shell.qml add:
//   VoicePill { id: voicePillItem; swayBorderWidth: root.swayBorderWidth }
// and inside the leftSide Row:
//   voicePillItem.pill   (the Rectangle)
// and at ShellRoot level:
//   voicePillItem.popup  (the VoicePopup)
//
// Or just inline both components as shown below — see shell.qml patch notes.

Item {
    id: voicePillRoot

    // ── Sidecar process ───────────────────────────────────────────────────────
    property var voiceUsers: []
    property bool inVoice: voiceUsers.length > 0

    Process {
        id: voiceSidecar
        command: ["node", "/home/zeke/projects/voiceSidecar/voiceSidecar.js"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                try {
                    var parsed = JSON.parse(data)
                    voicePillRoot.voiceUsers = parsed
                } catch(e) {}
            }
        }
    }
}
