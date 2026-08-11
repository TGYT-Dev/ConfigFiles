import QtQuick
import QtQuick.Layouts
import Quickshell.I3

Row {
    spacing: 0

    Repeater {
        model: I3.workspaces
        Rectangle {
            width: 22; height: 18
            color: modelData.focused ? "#3c3836"
                 : modelData.urgent  ? "#fbf1c7"
                 : wsHover.hovered   ? "#3c3836"
                 : "#282828"

            HoverHandler { id: wsHover }

            Text {
                anchors.centerIn: parent
                text: modelData.name
                color: modelData.focused ? "#ebdbb2" : (modelData.urgent ? "#3c3836" : "#ebdbb2")
                font.bold: modelData.focused
                font.family: "iosevka, monospace"
                font.pixelSize: 11
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: I3.dispatch("workspace " + modelData.name)
                onWheel: (event) => {
                    if (event.angleDelta.y < 0)
                        I3.dispatch("workspace next")
                    else
                        I3.dispatch("workspace prev")
                }
            }
        }
    }
}
