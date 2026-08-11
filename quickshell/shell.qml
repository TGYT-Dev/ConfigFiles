import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.I3
import Quickshell.Services.Mpris
import Quickshell.Io

ShellRoot {
    id: root

    readonly property int swayGapsInner: 4
    readonly property int swayGapsOuter: 2
    readonly property int swayBorderWidth: 3

    PanelWindow {
        id: bar
        anchors { top: true; left: true; right: true }
        exclusiveZone: bar.implicitHeight
        margins {
            top: swayGapsInner + swayGapsOuter
            left: swayGapsInner + swayGapsOuter
            right: swayGapsInner + swayGapsOuter
            bottom: 0
        }
        implicitHeight: 24
        color: "transparent"

        SystemStats { id: sysStats }
        NetworkStatus { id: netStatus }

        Item {
            anchors.fill: parent

            // ── Left Side: Workspaces, MiniPlayer & Window Title ──────────
            Row {
                id: leftSide
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: swayGapsInner

                // Workspaces pill
                Rectangle {
                    id: workspacesPill
                    height: parent.height
                    width: implicitWidth
                    implicitWidth: workspacesContent.implicitWidth + 12 - (swayBorderWidth * 2)
                    color: "#282828"
                    border.color: "#3c3836"
                    border.width: swayBorderWidth

                    Workspaces {
                        id: workspacesContent
                        anchors.centerIn: parent
                    }
                }

                // MiniPlayer pill
                Rectangle {
                    id: miniPlayerPill
                    height: parent.height
                    width: implicitWidth
                    implicitWidth: miniPlayerContent.implicitWidth + 12
                    color: "#282828"
                    border.color: "#3c3836"
                    border.width: swayBorderWidth
                    visible: miniPlayerContent.player !== null

                    MiniPlayer {
                        id: miniPlayerContent
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape:  Qt.PointingHandCursor
                        onClicked: playerWidget.open = !playerWidget.open
                    }
                }

                // Window Title pill
                Rectangle {
                    id: titlePill
                    height: parent.height
                    width: titleText.width + 12
                    color: "#282828"
                    border.color: "#3c3836"
                    border.width: swayBorderWidth
                    visible: (I3.focusedWindow && I3.focusedWindow.title && I3.focusedWindow.title.trim() !== "") ? true : false

                    Text {
                        id: titleText
                        anchors.centerIn: parent
                        text: I3.focusedWindow ? I3.focusedWindow.title : ""
                        color: "#ebdbb2"
                        font.family: "iosevka, monospace"
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        width: Math.min(implicitWidth, 250)
                    }
                }
            }

            // ── Right Side ────────────────────────────────────────────────
            Row {
                id: rightSide
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                spacing: swayGapsInner

                // ── Audio Controls pill ──────────────────────────────────
                Rectangle {
                    id: audioPill
                    height: parent.height
                    width: implicitWidth
                    implicitWidth: audioContent.implicitWidth + 12
                    color: "#282828"
                    border.color: "#3c3836"
                    border.width: swayBorderWidth

                    AudioControls {
                        id: audioContent
                        anchors.centerIn: parent
                        sysStats: sysStats
                        onVolumeClicked: {
                            micPopup.visible = false
                            volPopup.visible = !volPopup.visible
                        }
                        onMicClicked: {
                            volPopup.visible = false
                            micPopup.visible = !micPopup.visible
                        }
                    }
                }

                // ── Network Toggle pill ──────────────────────────────────
                //Rectangle {
                //    id: networkPill
                //    height: parent.height
                //    width: implicitWidth
                //    implicitWidth: networkContent.implicitWidth + 12
                //    color: "#282828"
                //    border.color: "#3c3836"
                //    border.width: swayBorderWidth

                //    NetworkToggle {
                //        id: networkContent
                //        anchors.centerIn: parent
                //        netStatus: netStatus
                //        onClicked: netPopup.open = !netPopup.open
                //    }
                //}

                // ── Stats pill ──────────────────────────────────────────
                Rectangle {
                    id: statsPill
                    height: parent.height
                    width: implicitWidth
                    implicitWidth: statsContent.implicitWidth + 12
                    color: "#282828"
                    border.color: "#3c3836"
                    border.width: swayBorderWidth

                    BarStats {
                        id: statsContent
                        anchors.centerIn: parent
                        sysStats: sysStats
                    }
                }

                // ── Clock/Date pill ─────────────────────────────────────
                Rectangle {
                    id: clockPill
                    height: parent.height
                    width: implicitWidth
                    implicitWidth: clockText.implicitWidth + 12
                    color: "#282828"
                    border.color: "#3c3836"
                    border.width: swayBorderWidth

                    Text {
                        id: clockText
                        anchors.centerIn: parent
                        color: "#8ec07c"
                        font.family: "iosevka, monospace"
                        font.pixelSize: 11

                        Timer {
                            interval: 1000; running: true; repeat: true
                            onTriggered: clockText.text = Qt.formatDateTime(new Date(), "dddd h:mm ap")
                        }
                        Component.onCompleted: text = Qt.formatDateTime(new Date(), "dddd h:mm ap")
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: calWidget.open = !calWidget.open
                    }
                }
            }
        }
    }

    // ─── Volume Popup ─────────────────────────────────────────────────────────
    PopupWindow {
        id: volPopup
        anchor.window: bar
        anchor.rect.y: bar.implicitHeight + 2
        implicitWidth: 50
        implicitHeight: 170
        visible: false

        property real anchorX: 0
        anchor.rect.x: anchorX
        onVisibleChanged: {
            if (visible) anchorX = audioPill.mapToItem(null, 0, 0).x
        }

        Rectangle {
            anchors.fill: parent
            color: "#282828"
            border.color: "#504945"
            border.width: 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(volSliderCustom.value) + "%"
                    color: "#fe8019"
                    font.family: "iosevka, monospace"
                    font.pixelSize: 10
                    font.bold: true
                }

                VolumeSlider {
                    id: volSliderCustom
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    fillColor: "#fe8019"

                    Connections {
                        target: sysStats
                        function onVolumeChanged() {
                            if (!volSliderCustom.pressed)
                                volSliderCustom.value = sysStats.volume
                        }
                    }
                    Component.onCompleted: value = sysStats.volume

                    Process {
                        id: setVolProc
                        command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (volSliderCustom.value / 100).toFixed(2)]
                    }

                    onMoved: function(v) {
                        setVolProc.running = false
                        setVolProc.running = true
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\uf028"
                    color: "#fe8019"
                    font.family: "Font Awesome 5 Free"
                    font.pixelSize: 12
                }
            }
        }
    }

    // ─── Mic Popup ────────────────────────────────────────────────────────────
    PopupWindow {
        id: micPopup
        anchor.window: bar
        anchor.rect.y: bar.implicitHeight + 2
        implicitWidth: 50
        implicitHeight: 170
        visible: false

        property real anchorX: 0
        anchor.rect.x: anchorX
        onVisibleChanged: {
            if (visible) anchorX = audioPill.mapToItem(null, audioPill.width / 2, 0).x
        }

        Rectangle {
            anchors.fill: parent
            color: "#282828"
            border.color: "#504945"
            border.width: 3

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 8
                spacing: 6

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: Math.round(micSliderCustom.value) + "%"
                    color: "#d3869b"
                    font.family: "iosevka, monospace"
                    font.pixelSize: 10
                    font.bold: true
                }

                VolumeSlider {
                    id: micSliderCustom
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    fillColor: "#d3869b"

                    Connections {
                        target: sysStats
                        function onMicVolumeChanged() {
                            if (!micSliderCustom.pressed)
                                micSliderCustom.value = sysStats.micVolume
                        }
                    }
                    Component.onCompleted: value = sysStats.micVolume

                    Process {
                        id: setMicProc
                        command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SOURCE@ " + (micSliderCustom.value / 100).toFixed(2)]
                    }

                    onMoved: function(v) {
                        setMicProc.running = false
                        setMicProc.running = true
                    }
                }

                Text {
                    Layout.alignment: Qt.AlignHCenter
                    text: "\uf130"
                    color: "#d3869b"
                    font.family: "Font Awesome 5 Free"
                    font.pixelSize: 12
                }
            }
        }
    }

    // ─── Calendar Popup ───────────────────────────────────────────────────────
    CalendarPopup {
        id: calWidget
        anchorWindow: bar
        anchorPill:   clockPill
        anchorY:      bar.implicitHeight + 2
        screenWidth:  bar.screen ? bar.screen.width : 1920
    }

    PlayerPopup {
        id: playerWidget
        anchorWindow: bar
        anchorPill:   miniPlayerPill
        anchorY:      bar.implicitHeight + 2
        screenWidth:  bar.screen ? bar.screen.width : 1920
    }

    NetworkPopup {
        id: netPopup
        anchorWindow: bar
        anchorPill:   networkPill
        anchorY:      bar.implicitHeight + 2
        screenWidth:  bar.screen ? bar.screen.width : 1920
        netStatus:    netStatus
    }


}
