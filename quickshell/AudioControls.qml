import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root
    spacing: 4

    required property QtObject sysStats

    signal volumeClicked()
    signal micClicked()

    // Speaker
    Item {
        id: volRow
        objectName: "volRow"
        implicitWidth: volInner.implicitWidth
        implicitHeight: volInner.implicitHeight

        RowLayout {
            id: volInner
            anchors.fill: parent
            spacing: 4

            Text {
                text: root.sysStats.volume < 1 ? "\uf026" : (root.sysStats.volume < 50 ? "\uf027" : "\uf028")
                color: "#fe8019"
                font.family: "Font Awesome 5 Free"
                font.pixelSize: 11
            }
            Text {
                text: Math.round(root.sysStats.volume) + "%"
                color: "#fe8019"
                font.family: "iosevka, monospace"
                font.pixelSize: 11
                Layout.minimumWidth: 26
                horizontalAlignment: Text.AlignRight
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.volumeClicked()
        }
    }

    // Mic
    Item {
        id: micRow
        objectName: "micRow"
        implicitWidth: micInner.implicitWidth
        implicitHeight: micInner.implicitHeight

        RowLayout {
            id: micInner
            anchors.fill: parent
            spacing: 4

            Text {
                text: "\uf130"
                color: "#d3869b"
                font.family: "Font Awesome 5 Free"
                font.pixelSize: 11
            }
            Text {
                text: Math.round(root.sysStats.micVolume) + "%"
                color: "#d3869b"
                font.family: "iosevka, monospace"
                font.pixelSize: 11
                Layout.minimumWidth: 26
                horizontalAlignment: Text.AlignRight
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.micClicked()
        }
    }
}
