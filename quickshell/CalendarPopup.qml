import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: calPopup

    property bool open: false
    property var anchorWindow: null
    property var anchorPill: null
    property int anchorY: 0
    property int screenWidth: 1920   // set from shell.qml: calWidget.screenWidth = bar.screen.width
    property real anchorX: 0

    property var today: new Date()
    property int viewYear:  today.getFullYear()
    property int viewMonth: today.getMonth()
    property var gcalEvents: []
    property bool gcalLoading: false
    property string gcalError: ""

    function daysInMonth(y, m) { return new Date(y, m + 1, 0).getDate() }
    function firstWeekday(y, m) { return new Date(y, m, 1).getDay() }
    function monthName(m) {
        return ["January","February","March","April","May","June",
                "July","August","September","October","November","December"][m]
    }
    function pad2(n) { return n < 10 ? "0" + n : "" + n }

    function buildGrid() {
        var cells = [], offset = firstWeekday(viewYear, viewMonth)
        var total = daysInMonth(viewYear, viewMonth)
        var prevTotal = daysInMonth(viewYear, viewMonth === 0 ? 11 : viewMonth - 1)
        for (var i = 0; i < offset; i++)
            cells.push({ day: prevTotal - offset + 1 + i, cur: false })
        for (var d = 1; d <= total; d++)
            cells.push({ day: d, cur: true })
        var t = 1
        while (cells.length < 42) cells.push({ day: t++, cur: false })
        return cells
    }

    property var gridCells: buildGrid()
    onViewMonthChanged: gridCells = buildGrid()
    onViewYearChanged:  gridCells = buildGrid()

    // ── gcalcli ───────────────────────────────────────────────────────────────
    Process {
        id: gcalProc
        property string buf: ""
        command: {
            var s = new Date(), e = new Date()
            e.setDate(e.getDate() + 30)
            var fmt = function(dt) {
                return dt.getFullYear() + "-" + calPopup.pad2(dt.getMonth()+1) + "-" + calPopup.pad2(dt.getDate())
            }
            // agenda takes positional [start] [end], --tsv for tab-separated output
            return ["bash", "-c",
                "gcalcli agenda --nocolor --tsv " + fmt(s) + " " + fmt(e)]
        }
        stdout: SplitParser {
            onRead: function(data) { gcalProc.buf += data + "\n" }
        }
        onExited: function(code) {
            calPopup.gcalLoading = false
            if (code !== 0) { calPopup.gcalError = "gcalcli failed (code " + code + ")"; return }
            calPopup.gcalError = ""
            var events = [], lines = gcalProc.buf.trim().split("\n")
            for (var i = 0; i < lines.length; i++) {
                var p = lines[i].split("\t")
                // TSV: startDate, startTime, endDate, endTime, title
                // Skip header row (first field won't parse as a date)
                if (p.length >= 5 && /^\d{4}-\d{2}-\d{2}$/.test(p[0].trim()))
                    events.push({ date: p[0].trim(), start: p[1].trim(), title: p[4].trim() })
            }
            calPopup.gcalEvents = events
        }
    }

    function refreshGcal() {
        gcalProc.buf = ""; gcalLoading = true; gcalError = ""; gcalEvents = []
        gcalProc.running = false; gcalProc.running = true
    }

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
            refreshGcal()
        }
    }
    Timer { interval: 1000; running: calPopup.open; repeat: true; onTriggered: calPopup.today = new Date() }

    // ── Popup ─────────────────────────────────────────────────────────────────
    PopupWindow {
        id: popWin
        visible: calPopup.open
        implicitWidth:  520
        implicitHeight: 320
        anchor.window: calPopup.anchorWindow
        anchor.rect.y: calPopup.anchorY
        anchor.rect.x: calPopup.anchorX

        Rectangle {
            id: bg
            anchors.fill: parent
            color: "#282828"
            border.color: "#3c3836"
            border.width: 3

            // ── Vertical divider — anchored so it meets hDiv endpoints ──
            Rectangle {
                id: vDiv
                anchors.top:    bg.top
                anchors.bottom: bg.bottom
                anchors.topMargin:    bg.border.width
                anchors.bottomMargin: bg.border.width
                // Center it in the gap between leftCol right edge and right column left edge
                x: bg.border.width + leftCol.width + (mainRow.spacing / 2)
                width: 1
                color: "#504945"
                z: 2
            }

            RowLayout {
                id: mainRow
                anchors.fill: parent
                anchors.margins: bg.border.width
                spacing: 24

                // ═══════════════════════════════════════════════
                // LEFT COLUMN
                // ═══════════════════════════════════════════════
                Item {
                    id: leftCol
                    Layout.preferredWidth: 170
                    Layout.fillHeight: true

                    // Top half: clock (vertically centered)
                    Item {
                        id: clockHalf
                        anchors.top:   parent.top
                        anchors.left:  parent.left
                        anchors.right: parent.right
                        height: parent.height * 0.5

                        Item {
                            id: clockFace
                            width: 110; height: 110
                            anchors.centerIn: parent

                            readonly property real cx: width  / 2
                            readonly property real cy: height / 2
                            readonly property real r:  Math.min(width, height) / 2 - 3
                            readonly property int hrs:  calPopup.today.getHours()   % 12
                            readonly property int mins: calPopup.today.getMinutes()
                            readonly property int secs: calPopup.today.getSeconds()

                            Canvas {
                                anchors.fill: parent
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)
                                    var cx = clockFace.cx, cy = clockFace.cy, r = clockFace.r
                                    ctx.beginPath(); ctx.arc(cx, cy, r, 0, Math.PI*2)
                                    ctx.fillStyle = "#3c3836"; ctx.fill()
                                    ctx.strokeStyle = "#504945"; ctx.lineWidth = 1.5; ctx.stroke()
                                    for (var i = 0; i < 12; i++) {
                                        var a = (i/12)*Math.PI*2 - Math.PI/2
                                        var inner = (i%3===0) ? r-10 : r-6
                                        ctx.beginPath()
                                        ctx.moveTo(cx + Math.cos(a)*inner, cy + Math.sin(a)*inner)
                                        ctx.lineTo(cx + Math.cos(a)*(r-2), cy + Math.sin(a)*(r-2))
                                        ctx.strokeStyle = (i%3===0) ? "#8ec07c" : "#665c54"
                                        ctx.lineWidth   = (i%3===0) ? 2 : 1
                                        ctx.stroke()
                                    }
                                }
                            }

                            Canvas {
                                id: handsCanvas
                                anchors.fill: parent
                                Connections {
                                    target: calPopup
                                    function onTodayChanged() { handsCanvas.requestPaint() }
                                }
                                Component.onCompleted: requestPaint()
                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.clearRect(0, 0, width, height)
                                    var cx = clockFace.cx, cy = clockFace.cy, r = clockFace.r
                                    var h = clockFace.hrs, m = clockFace.mins, s = clockFace.secs
                                    // hour
                                    var ha = ((h + m/60)/12)*Math.PI*2 - Math.PI/2
                                    ctx.beginPath(); ctx.moveTo(cx,cy)
                                    ctx.lineTo(cx+Math.cos(ha)*r*0.52, cy+Math.sin(ha)*r*0.52)
                                    ctx.strokeStyle="#ebdbb2"; ctx.lineWidth=3; ctx.lineCap="round"; ctx.stroke()
                                    // minute
                                    var ma = ((m + s/60)/60)*Math.PI*2 - Math.PI/2
                                    ctx.beginPath(); ctx.moveTo(cx,cy)
                                    ctx.lineTo(cx+Math.cos(ma)*r*0.75, cy+Math.sin(ma)*r*0.75)
                                    ctx.strokeStyle="#ebdbb2"; ctx.lineWidth=2; ctx.lineCap="round"; ctx.stroke()
                                    // second
                                    var sa = (s/60)*Math.PI*2 - Math.PI/2
                                    ctx.beginPath(); ctx.moveTo(cx,cy)
                                    ctx.lineTo(cx+Math.cos(sa)*r*0.82, cy+Math.sin(sa)*r*0.82)
                                    ctx.strokeStyle="#fb4934"; ctx.lineWidth=1; ctx.lineCap="round"; ctx.stroke()
                                    // dot
                                    ctx.beginPath(); ctx.arc(cx,cy,3,0,Math.PI*2)
                                    ctx.fillStyle="#fb4934"; ctx.fill()
                                }
                            }
                        }
                    }

                    // Horizontal divider — spans from bg left border to vDiv
                    Rectangle {
                        anchors.left: bg.left
                        anchors.leftMargin: bg.border.width
                        width: leftCol.width + (mainRow.spacing / 2)
                        y: leftCol.height * 0.5
                        height: 1
                        color: "#504945"
                    }

                    // Bottom half: upcoming events
                    Item {
                        id: eventsHalf
                        anchors.bottom: parent.bottom
                        anchors.left:   parent.left
                        anchors.right:  parent.right
                        height: parent.height * 0.5

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.topMargin: 8
                            anchors.bottomMargin: 4
                            spacing: 6

                            Text {
                                text: "Upcoming events"; color: "#a89984"
                                font.family: "iosevka, monospace"; font.pixelSize: 10; font.bold: true
                            }

                            Text {
                                visible: calPopup.gcalLoading; text: "Loading…"; color: "#665c54"
                                font.family: "iosevka, monospace"; font.pixelSize: 9
                            }
                            Text {
                                visible: !calPopup.gcalLoading && calPopup.gcalError !== ""
                                text: calPopup.gcalError; color: "#fb4934"
                                font.family: "iosevka, monospace"; font.pixelSize: 9
                                wrapMode: Text.WordWrap; Layout.fillWidth: true
                            }

                            Repeater {
                                model: Math.min(calPopup.gcalEvents.length, 4)
                                delegate: ColumnLayout {
                                    spacing: 1; Layout.fillWidth: true
                                    required property int index
                                    readonly property var ev: calPopup.gcalEvents[index]
                                    Text {
                                        text: ev.date + "  " + ev.start
                                        color: "#8ec07c"; font.family: "iosevka, monospace"; font.pixelSize: 9
                                    }
                                    Text {
                                        text: ev.title; color: "#ebdbb2"
                                        font.family: "iosevka, monospace"; font.pixelSize: 10
                                        elide: Text.ElideRight; Layout.fillWidth: true
                                    }
                                }
                            }

                            Text {
                                visible: !calPopup.gcalLoading && calPopup.gcalEvents.length === 0 && calPopup.gcalError === ""
                                text: "No upcoming events"; color: "#665c54"
                                font.family: "iosevka, monospace"; font.pixelSize: 10
                            }

                            Item { Layout.fillHeight: true }
                        }
                    }
                }

                // ═══════════════════════════════════════════════
                // RIGHT COLUMN — calendar grid
                // ═══════════════════════════════════════════════
                ColumnLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true
                    spacing: 4

                    // Month nav
                    RowLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "\uf053"; color: "#a89984"
                            font.family: "Font Awesome 5 Free"; font.pixelSize: 10
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (calPopup.viewMonth === 0) { calPopup.viewMonth = 11; calPopup.viewYear-- }
                                    else calPopup.viewMonth--
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: calPopup.monthName(calPopup.viewMonth) + "  " + calPopup.viewYear
                            color: "#ebdbb2"; font.family: "iosevka, monospace"
                            font.pixelSize: 12; font.bold: true
                        }
                        Item { Layout.fillWidth: true }
                        Text {
                            text: "\uf054"; color: "#a89984"
                            font.family: "Font Awesome 5 Free"; font.pixelSize: 10
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (calPopup.viewMonth === 11) { calPopup.viewMonth = 0; calPopup.viewYear++ }
                                    else calPopup.viewMonth++
                                }
                            }
                        }
                    }

                    // DoW headers
                    Item {
                        id: dowRow
                        Layout.fillWidth: true
                        height: 14
                        Row {
                            anchors.fill: parent
                            Repeater {
                                model: ["Su","Mo","Tu","We","Th","Fr","Sa"]
                                delegate: Text {
                                    width: dowRow.width / 7
                                    horizontalAlignment: Text.AlignHCenter
                                    text: modelData; color: "#a89984"
                                    font.family: "iosevka, monospace"; font.pixelSize: 9; font.bold: true
                                }
                            }
                        }
                    }

                    // Grid
                    Item {
                        id: calGrid
                        Layout.fillWidth: true; Layout.fillHeight: true

                        Grid {
                            anchors.fill: parent
                            columns: 7; columnSpacing: 2; rowSpacing: 2

                            Repeater {
                                model: calPopup.gridCells.length
                                delegate: Item {
                                    id: cell
                                    width:  (calGrid.width  - 6*2) / 7
                                    height: (calGrid.height - 5*2) / 6
                                    required property int index
                                    readonly property var cd: calPopup.gridCells[index]

                                    readonly property bool isToday:
                                        cd.cur &&
                                        cd.day === calPopup.today.getDate() &&
                                        calPopup.viewMonth === calPopup.today.getMonth() &&
                                        calPopup.viewYear  === calPopup.today.getFullYear()

                                    readonly property bool hasEvent: {
                                        if (!cd.cur) return false
                                        var ds = calPopup.viewYear + "-" +
                                                 calPopup.pad2(calPopup.viewMonth+1) + "-" +
                                                 calPopup.pad2(cd.day)
                                        for (var i = 0; i < calPopup.gcalEvents.length; i++)
                                            if (calPopup.gcalEvents[i].date === ds) return true
                                        return false
                                    }

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: Math.min(parent.width, parent.height) - 4; height: width
                                        radius: width / 2
                                        visible: cell.isToday || cell.hasEvent
                                        color:   cell.isToday ? "#8ec07c" : "#83a598"
                                        opacity: cell.isToday ? 0.35 : 0.28
                                    }
                                    Text {
                                        anchors.centerIn: parent
                                        text: cell.cd.day
                                        font.family: "iosevka, monospace"; font.pixelSize: 10
                                        font.bold: cell.isToday || cell.hasEvent
                                        color: cell.isToday  ? "#8ec07c"  :
                                               cell.hasEvent ? "#83a598"  :
                                               !cell.cd.cur  ? "#504945"  : "#ebdbb2"
                                    }
                                }
                            }
                        }
                    }

                    // Sync
                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        Text {
                            id: syncBtn; text: "\uf021  Sync"; color: "#504945"
                            font.family: "iosevka, monospace"; font.pixelSize: 9
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -4; cursorShape: Qt.PointingHandCursor
                                hoverEnabled: true
                                onEntered: syncBtn.color = "#a89984"
                                onExited:  syncBtn.color = "#504945"
                                onClicked: calPopup.refreshGcal()
                            }
                        }
                    }
                }
            }
        }
    }
}
