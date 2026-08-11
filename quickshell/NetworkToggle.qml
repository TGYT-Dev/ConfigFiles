import QtQuick
import QtQuick.Layouts

// Bar pill content — shows current state, click opens NetworkPopup (wired in shell.qml)
Item {
    id: root
    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight

    required property QtObject netStatus

    signal clicked()

    function stateColor() {
        if (root.netStatus.state === "warp") return "#fe8019"
        return "#d3869b" // default/tailscale
    }

    function stateIcon() {
        if (root.netStatus.state === "warp") return "\ue792"
        return "\uef09" // default/tailscale
    }

    function stateLabel() {
        if (root.netStatus.state === "warp") return "WARP"
        return "Tailscale"
    }

    RowLayout {
        id: rowLayout
        anchors.fill: parent
        spacing: 4

        Text {
            text: root.stateIcon()
            color: root.stateColor()
            font.family: "JetBrainsMono Nerd Font Mono"
            font.pixelSize: 15
        }

        Text {
            text: root.stateLabel()
            color: root.stateColor()
            font.family: "iosevka, monospace"
            font.pixelSize: 11
        }
    }

    MouseArea {
        anchors.fill: parent
        anchors.margins: -4
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
