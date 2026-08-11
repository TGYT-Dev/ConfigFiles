import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

RowLayout {
    id: root
    spacing: 6
    implicitHeight: 18
    height: 18
    visible: playerList && playerList.length > 0

    readonly property var playerList: Mpris.players.values
    readonly property MprisPlayer player: playerList && playerList.length > 0 ? playerList[0] : null

    HoverHandler { id: mediaHover }

    // Back
    Text {
        text: "\uf048"
        color: "#83a598"
        font.family: "Font Awesome 5 Free"
        font.pixelSize: 11
        MouseArea {
            anchors.fill: parent
            anchors.margins: -2
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.player) root.player.previous()
        }
    }

    // Play/Pause
    Text {
        text: (root.player && root.player.playbackState === MprisPlaybackState.Playing) ? "\uf04c" : "\uf04b"
        color: "#83a598"
        font.family: "Font Awesome 5 Free"
        font.pixelSize: 11
        MouseArea {
            anchors.fill: parent
            anchors.margins: -2
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.player) root.player.togglePlaying()
        }
    }

    // Skip
    Text {
        text: "\uf051"
        color: "#83a598"
        font.family: "Font Awesome 5 Free"
        font.pixelSize: 11
        MouseArea {
            anchors.fill: parent
            anchors.margins: -2
            cursorShape: Qt.PointingHandCursor
            onClicked: if (root.player) root.player.next()
        }
    }

    // Song name
    Text {
        text: {
            if (!root.player) return ""
            var title = root.player.trackTitle ?? ""
            var artist = root.player.trackArtist ?? ""
            return (mediaHover.hovered && artist) ? (title + " \u2013 " + artist) : title
        }
        color: "#ebdbb2"
        font.family: "iosevka, monospace"
        font.pixelSize: 11
        elide: Text.ElideRight
        Layout.preferredWidth: implicitWidth
        Behavior on Layout.preferredWidth {
            NumberAnimation { duration: 400; easing.type: Easing.OutCubic }
        }
    }
}
