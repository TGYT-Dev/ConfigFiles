import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// A simple vertical slider: drag or click anywhere to set value
// Value range: 0-100. Handle at top = 100, bottom = 0.
Item {
    id: root
    implicitWidth: 20
    
    property real value: 50
    property color fillColor: "#fe8019"
    property color trackColor: "#3c3836"
    readonly property alias pressed: dragArea.pressed

    signal moved(real newValue)

    // Track background
    Rectangle {
        id: track
        width: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        color: trackColor
        border.color: "#504945"
        border.width: 1

        // Filled portion (bottom up)
        Rectangle {
            width: parent.width
            height: (root.value / 100) * parent.height
            anchors.bottom: parent.bottom
            color: root.fillColor
        }
    }

    // Handle
    Rectangle {
        id: handle
        width: 14; height: 14
        anchors.horizontalCenter: parent.horizontalCenter
        // top=100%, bottom=0%
        y: (1 - root.value / 100) * (root.height - height)
        color: dragArea.pressed ? Qt.darker(root.fillColor, 1.3) : root.fillColor
        border.color: "#282828"
        border.width: 1
    }

    MouseArea {
        id: dragArea
        anchors.fill: parent
        preventStealing: true

        function valueFromY(my) {
            var ratio = 1.0 - Math.max(0, Math.min(root.height, my)) / root.height
            return Math.round(ratio * 100)
        }

        onPressed: {
            root.value = valueFromY(mouseY)
            root.moved(root.value)
        }
        onPositionChanged: {
            if (pressed) {
                root.value = valueFromY(mouseY)
                root.moved(root.value)
            }
        }
    }
}
