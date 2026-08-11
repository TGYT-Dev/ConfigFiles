import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: netPopup

    property bool open: false
    property var anchorWindow: null
    property var anchorPill: null
    property int anchorY: 0
    property int screenWidth: 1920
    property real anchorX: 0

    required property QtObject netStatus

    function updateAnchorX() {
        if (!anchorPill || !anchorWindow) {
            anchorX = 0
            return
        }
        var pos = anchorPill.mapToItem(null, 0, 0)
        var rightAligned = pos.x + anchorPill.width - popWin.implicitWidth
        anchorX = Math.max(0, Math.min(screenWidth - popWin.implicitWidth - 4, rightAligned))
    }

    onOpenChanged: {
        if (open) {
            updateAnchorX()
            netStatus.refresh()
        }
    }

    function bigColor() {
        if (netStatus.state === "warp") return "#fe8019"
        return "#d3869b"
    }

    function bigIcon() {
        if (netStatus.state === "warp") return "\ue792"
        return "\uef09"
    }

    function bigLabel() {
        if (netStatus.state === "warp") return "Connected — WARP"
        return "Connected — Tailscale"
    }

    PopupWindow {
        id: popWin
        visible: netPopup.open
        implicitWidth: 170
        implicitHeight: 210
        anchor.window: netPopup.anchorWindow
        anchor.rect.y: netPopup.anchorY
        anchor.rect.x: netPopup.anchorX

        Rectangle {
            anchors.fill: parent
            color: "#282828"
            border.color: "#3c3836"
            border.width: 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                // ── Big status icon ──────────────────────────────────
                ColumnLayout {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 6
                    spacing: 8

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        width: 64
                        height: 64
                        radius: 32
                        color: "#3c3836"
                        border.color: netPopup.bigColor()
                        border.width: 2

                        Text {
                            anchors.centerIn: parent
                            text: netPopup.bigIcon()
                            color: netPopup.bigColor()
                            font.family: "JetBrainsMono Nerd Font Mono"
                            font.pixelSize: 34
                        }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: netStatus.isBusy ? "Switching..." : netPopup.bigLabel()
                        color: netPopup.bigColor()
                        font.family: "iosevka, monospace"
                        font.pixelSize: 12
                        font.bold: true
                    }
                }

                Item { Layout.fillHeight: true }

                // ── Single swap button ────────────────────────────────
                Rectangle {
                    id: swapBtn
                    Layout.fillWidth: true
                    implicitHeight: 32
                    color: "#3c3836"
                    border.color: hoverArea.containsMouse ? swapBtn.targetColor : "#504945"
                    border.width: 3

                    readonly property bool targetIsWarp: netStatus.state !== "warp"
                    readonly property color targetColor: targetIsWarp ? "#fe8019" : "#d3869b"

                    Text {
                        anchors.centerIn: parent
                        text: netStatus.isBusy
                            ? "Switching..."
                            : "Switch to " + (swapBtn.targetIsWarp ? "WARP" : "Tailscale")
                        color: swapBtn.targetColor
                        font.family: "iosevka, monospace"
                        font.pixelSize: 11
                    }

                    MouseArea {
                        id: hoverArea
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        hoverEnabled: true
                        enabled: !netStatus.isBusy
                        onClicked: netStatus.setState(swapBtn.targetIsWarp ? "warp" : "tailscale")
                    }
                }
            }
        }
    }
}
