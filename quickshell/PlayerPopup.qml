import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

Item {
    id: playerPopup

    property bool open: false
    property var anchorWindow: null
    property var anchorPill: null
    property int anchorY: 0
    property int screenWidth: 1920
    property real anchorX: 0

    readonly property var playerList: Mpris.players.values
    readonly property MprisPlayer player: playerList && playerList.length > 0 ? playerList[0] : null
    onOpenChanged: {
        if (open && player) {
            updateAnchorX()
            player.positionChanged()
        }
    }
    onPlayerChanged: {
        if (player)
            player.positionChanged()
    }

    // position and length are seconds (float)
    function formatSecs(secs) {
        if (!secs || isNaN(secs) || secs < 0) return "0:00"
        var s = Math.floor(secs)
        var m = Math.floor(s / 60)
        s = s % 60
        return m + ":" + (s < 10 ? "0" + s : s)
    }

    function updateAnchorX() {
        if (!anchorPill || !anchorWindow) {
            anchorX = 0
            return
        }

        var pos = anchorPill.mapToItem(null, 0, 0)
        anchorX = Math.max(0, Math.min(screenWidth - popWin.implicitWidth - 4, pos.x))
    }

    FrameAnimation {
        running: playerPopup.open && playerPopup.player !== null &&
                 playerPopup.player.playbackState === MprisPlaybackState.Playing
        onTriggered: if (playerPopup.player) playerPopup.player.positionChanged()
    }

    // Also update progress when paused/seeking or tracks change.
    Connections {
        target: playerPopup.player
        function onTrackChanged() {
            if (playerPopup.player)
                playerPopup.player.positionChanged()
        }
    }

    PopupWindow {
        id: popWin
        visible: playerPopup.open && playerPopup.player !== null
        implicitWidth:  340
        implicitHeight: 130

        anchor.window: playerPopup.anchorWindow
        anchor.rect.y: playerPopup.anchorY
        anchor.rect.x: playerPopup.anchorX

        Rectangle {
            anchors.fill: parent
            color:        "#282828"
            border.color: "#3c3836"
            border.width: 3

            RowLayout {
                anchors.fill:    parent
                anchors.margins: 12
                spacing:         12

                // ── Album art ─────────────────────────────────────────────
                Rectangle {
                    width:  90
                    height: 90
                    color:  "#3c3836"
                    radius: 4
                    Layout.alignment: Qt.AlignVCenter
                    clip: true

                    Image {
                        id: albumArt
                        anchors.fill: parent
                        source:       playerPopup.player ? (playerPopup.player.trackArtUrl ?? "") : ""
                        fillMode:     Image.PreserveAspectCrop
                        smooth:       true
                        visible:      status === Image.Ready
                    }

                    Text {
                        anchors.centerIn: parent
                        visible:          albumArt.status !== Image.Ready
                        text:             "\uf001"
                        color:            "#504945"
                        font.family:      "Font Awesome 5 Free"
                        font.pixelSize:   34
                    }
                }

                // ── Right side ────────────────────────────────────────────
                ColumnLayout {
                    Layout.fillWidth:  true
                    Layout.fillHeight: true
                    spacing:           6

                    // Title
                    Text {
                        text:             playerPopup.player ? (playerPopup.player.trackTitle ?? "Unknown") : ""
                        color:            "#ebdbb2"
                        font.family:      "iosevka, monospace"
                        font.pixelSize:   13
                        font.bold:        true
                        elide:            Text.ElideRight
                        Layout.fillWidth: true
                    }

                    // Artist — Album
                    Text {
                        text: {
                            if (!playerPopup.player) return ""
                            var artist = playerPopup.player.trackArtist ?? ""
                            var album  = playerPopup.player.trackAlbum  ?? ""
                            if (artist && album) return artist + "  \u2013  " + album
                            return artist || album
                        }
                        color:            "#a89984"
                        font.family:      "iosevka, monospace"
                        font.pixelSize:   10
                        elide:            Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    // ── Controls ──────────────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Item { Layout.fillWidth: true }

                        // Shuffle
                        Text {
                            text:           "\uf074"
                            color:          (playerPopup.player && playerPopup.player.shuffle) ? "#b8bb26" : "#665c54"
                            font.family:    "Font Awesome 5 Free"
                            font.pixelSize: 11
                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -5
                                cursorShape:     Qt.PointingHandCursor
                                onClicked:       if (playerPopup.player) playerPopup.player.shuffle = !playerPopup.player.shuffle
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Previous
                        Text {
                            text:           "\uf048"
                            color:          "#83a598"
                            font.family:    "Font Awesome 5 Free"
                            font.pixelSize: 14
                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -5
                                cursorShape:     Qt.PointingHandCursor
                                onClicked:       if (playerPopup.player) playerPopup.player.previous()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Play/Pause
                        Text {
                            text:           (playerPopup.player && playerPopup.player.playbackState === MprisPlaybackState.Playing)
                                            ? "\uf04c" : "\uf04b"
                            color:          "#ebdbb2"
                            font.family:    "Font Awesome 5 Free"
                            font.pixelSize: 18
                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -5
                                cursorShape:     Qt.PointingHandCursor
                                onClicked:       if (playerPopup.player) playerPopup.player.togglePlaying()
                            }
                        }

                        Item { Layout.fillWidth: true }

                        // Next
                        Text {
                            text:           "\uf051"
                            color:          "#83a598"
                            font.family:    "Font Awesome 5 Free"
                            font.pixelSize: 14
                            MouseArea {
                                anchors.fill:    parent
                                anchors.margins: -5
                                cursorShape:     Qt.PointingHandCursor
                                onClicked:       if (playerPopup.player) playerPopup.player.next()
                            }
                        }

                        Item { Layout.fillWidth: true }
                    }

                    // ── Scrub bar ─────────────────────────────────────────
                    RowLayout {
                        Layout.fillWidth: true
                        spacing:          5

                        Text {
                            id: elapsedText
                            text:           playerPopup.formatSecs(playerPopup.player ? playerPopup.player.position : 0)
                            color:          "#665c54"
                            font.family:    "iosevka, monospace"
                            font.pixelSize: 9
                        }

                        // Horizontal progress bar — same pattern as VolumeSlider
                        Item {
                            id: scrubBar
                            Layout.fillWidth: true
                            height: 14

                            readonly property real duration: playerPopup.player && playerPopup.player.lengthSupported ? playerPopup.player.length : 0
                            readonly property real progress: {
                                if (!playerPopup.player || duration <= 0) return 0
                                return Math.max(0, Math.min(1, playerPopup.player.position / duration))
                            }

                            // Track background
                            Rectangle {
                                id: scrubTrack
                                anchors.verticalCenter: parent.verticalCenter
                                width:  parent.width
                                height: 4
                                color:  "#3c3836"
                                border.color: "#504945"
                                border.width: 1

                                // Filled portion — left to right
                                Rectangle {
                                    anchors.left:   parent.left
                                    anchors.top:    parent.top
                                    anchors.bottom: parent.bottom
                                    width:  scrubBar.progress * parent.width
                                    color:  "#83a598"
                                }
                            }

                            // Handle
                            Rectangle {
                                id: scrubHandle
                                anchors.verticalCenter: parent.verticalCenter
                                x:      scrubBar.progress * (scrubBar.width - width)
                                width:  14
                                height: 14
                                color:  dragArea.pressed ? Qt.darker("#83a598", 1.3) : "#83a598"
                                border.color: "#282828"
                                border.width: 1
                            }

                            MouseArea {
                                id: dragArea
                                anchors.fill:     parent
                                preventStealing:  true
                                cursorShape:      Qt.PointingHandCursor

                                function seek(mx) {
                                    if (!playerPopup.player || scrubBar.duration <= 0 ||
                                        !playerPopup.player.canSeek || !playerPopup.player.positionSupported) return
                                    var ratio = Math.max(0, Math.min(1, mx / scrubBar.width))
                                    playerPopup.player.position = ratio * scrubBar.duration
                                    playerPopup.player.positionChanged()
                                }

                                onPressed:         seek(mouseX)
                                onPositionChanged: { if (pressed) seek(mouseX) }
                            }
                        }

                        Text {
                            text:           playerPopup.formatSecs(scrubBar.duration)
                            color:          "#665c54"
                            font.family:    "iosevka, monospace"
                            font.pixelSize: 9
                        }
                    }
                }
            }
        }
    }
}
