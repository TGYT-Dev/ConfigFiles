import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: voicePopup

    property bool open: false
    property var anchorWindow: null
    property var anchorPill: null
    property int anchorY: 0
    property int screenWidth: 1920
    property real anchorX: 0

    // Passed in from shell.qml — the shared voiceUsers array from VoiceState
    property var voiceUsers: []

    function updateAnchorX() {
        if (!anchorPill || !anchorWindow) { anchorX = 0; return }
        var pos = anchorPill.mapToItem(null, 0, 0)
        anchorX = Math.max(0, Math.min(screenWidth - popWin.implicitWidth - 4, pos.x))
    }

    onOpenChanged: { if (open) updateAnchorX() }

    PopupWindow {
        id: popWin
        visible: voicePopup.open && voicePopup.voiceUsers.length > 0
        implicitWidth:  220
        implicitHeight: Math.max(60, headerRow.height + 16 + userList.implicitHeight + 16)

        anchor.window: voicePopup.anchorWindow
        anchor.rect.y: voicePopup.anchorY
        anchor.rect.x: voicePopup.anchorX

        Rectangle {
            anchors.fill: parent
            color:        "#282828"
            border.color: "#3c3836"
            border.width: 3

            ColumnLayout {
                anchors.fill:         parent
                anchors.margins:      12
                anchors.topMargin:    10
                anchors.bottomMargin: 10
                spacing:              8

                // ── Header ───────────────────────────────────────────────
                RowLayout {
                    id: headerRow
                    Layout.fillWidth: true
                    spacing: 6

                    Text {
                        text:           "\uf130"
                        color:          "#8ec07c"
                        font.family:    "Font Awesome 5 Free"
                        font.pixelSize: 11
                    }

                    Text {
                        text:           "Voice Channel"
                        color:          "#a89984"
                        font.family:    "iosevka, monospace"
                        font.pixelSize: 10
                        font.bold:      true
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text:           voicePopup.voiceUsers.length + " connected"
                        color:          "#665c54"
                        font.family:    "iosevka, monospace"
                        font.pixelSize: 9
                    }
                }

                // ── Divider ───────────────────────────────────────────────
                Rectangle {
                    Layout.fillWidth: true
                    height:           1
                    color:            "#504945"
                }

                // ── User list ─────────────────────────────────────────────
                ColumnLayout {
                    id: userList
                    Layout.fillWidth: true
                    spacing: 5

                    Repeater {
                        model: voicePopup.voiceUsers.length
                        delegate: RowLayout {
                            id: userRow
                            Layout.fillWidth: true
                            spacing: 7

                            required property int index
                            readonly property var user: voicePopup.voiceUsers[index]

                            // Speaking indicator bar
                            Rectangle {
                                width:  3
                                height: 16
                                radius: 2
                                color:  userRow.user.speaking ? "#b8bb26"
                                        : userRow.user.mute   ? "#fb4934"
                                        : userRow.user.deaf   ? "#d3869b"
                                        : "#3c3836"

                                Behavior on color {
                                    ColorAnimation { duration: 80 }
                                }
                            }

                            // Username
                            Text {
                                text:             userRow.user.username ?? ""
                                color:            userRow.user.speaking ? "#ebdbb2" : "#a89984"
                                font.family:      "iosevka, monospace"
                                font.pixelSize:   11
                                font.bold:        userRow.user.speaking
                                elide:            Text.ElideRight
                                Layout.fillWidth: true

                                Behavior on color {
                                    ColorAnimation { duration: 80 }
                                }
                            }

                            // Status icons (mute / deaf)
                            Row {
                                spacing: 4

                                Text {
                                    visible:        userRow.user.mute && !userRow.user.deaf
                                    text:           "\uf131"
                                    color:          "#fb4934"
                                    font.family:    "Font Awesome 5 Free"
                                    font.pixelSize: 9
                                }

                                Text {
                                    visible:        userRow.user.deaf
                                    text:           "\uf2a2"
                                    color:          "#d3869b"
                                    font.family:    "Font Awesome 5 Free"
                                    font.pixelSize: 9
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
