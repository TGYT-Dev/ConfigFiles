import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 14

    required property QtObject sysStats

    // Memory
    RowLayout {
        spacing: 4
        Text { text: "\uf233"; color: "#b8bb26"; font.family: "Font Awesome 5 Free"; font.pixelSize: 11 }
        Rectangle {
            width: 35; height: 12
            color: "#3c3836"; border.color: "#504945"; border.width: 1; clip: true
            LineGraph { anchors.fill: parent; anchors.margins: 1; graphColor: "#b8bb26"; currentValue: root.sysStats.memoryUsage }
        }
        Text {
            text: Math.round(root.sysStats.memoryUsage * 100) + "%"
            color: "#b8bb26"; font.family: "iosevka, monospace"; font.pixelSize: 11
            Layout.minimumWidth: 25; horizontalAlignment: Text.AlignRight
        }
    }

    // CPU
    RowLayout {
        spacing: 4
        Text { text: "\uf2db"; color: "#ebdbb2"; font.family: "Font Awesome 5 Free"; font.pixelSize: 11 }
        Rectangle {
            width: 35; height: 12
            color: "#3c3836"; border.color: "#504945"; border.width: 1; clip: true
            LineGraph { anchors.fill: parent; anchors.margins: 1; graphColor: "#ebdbb2"; currentValue: root.sysStats.cpuUsage }
        }
        Text {
            text: Math.round(root.sysStats.cpuUsage * 100) + "%"
            color: "#ebdbb2"; font.family: "iosevka, monospace"; font.pixelSize: 11
            Layout.minimumWidth: 25; horizontalAlignment: Text.AlignRight
        }
    }
}
