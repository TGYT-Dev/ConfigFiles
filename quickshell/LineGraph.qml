import QtQuick

Item {
    id: root
    property var history: []
    property real currentValue: 0
    property int maxHistory: 30
    property color graphColor: "#fabd2f"
    
    onCurrentValueChanged: {
        var newHistory = history.slice();
        newHistory.push(currentValue);
        if (newHistory.length > maxHistory) {
            newHistory.shift();
        }
        history = newHistory;
        canvas.requestPaint();
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height);
            if (root.history.length === 0) return;
            
            ctx.beginPath();
            ctx.lineWidth = 2;
            ctx.strokeStyle = root.graphColor;
            
            var stepX = width / (root.maxHistory - 1);
            
            for (var i = 0; i < root.history.length; i++) {
                var x = i * stepX;
                // Clamp value to 0-1
                var val = Math.max(0, Math.min(1, root.history[i]));
                var y = height - (val * height);
                if (i === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            }
            ctx.stroke();
            
            // Fill area under graph
            ctx.lineTo((root.history.length - 1) * stepX, height);
            ctx.lineTo(0, height);
            ctx.closePath();
            ctx.fillStyle = Qt.rgba(root.graphColor.r, root.graphColor.g, root.graphColor.b, 0.2);
            ctx.fill();
        }
    }
}
