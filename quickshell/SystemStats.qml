import QtQuick
import Quickshell.Io

Item {
    id: root
    property real cpuUsage: 0
    property real memoryUsage: 0
    property real volume: 0
    property real micVolume: 0
    
    Process {
        id: memProc
        command: ["bash", "-c", "free | awk '/Mem/ {print $3/$2}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var mem = parseFloat(text);
                if (!isNaN(mem)) root.memoryUsage = mem;
            }
        }
    }
    
    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | sed 's/.*, *\\([0-9.]*\\)%* id.*/\\1/' | awk '{print (100 - $1)/100}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var cpu = parseFloat(text);
                if (!isNaN(cpu)) root.cpuUsage = cpu;
            }
        }
    }
    
    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print $2 * 100}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var vol = parseFloat(text);
                if (!isNaN(vol)) root.volume = vol;
            }
        }
    }
    
    Process {
        id: micVolProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk '{print $2 * 100}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                var vol = parseFloat(text);
                if (!isNaN(vol)) root.micVolume = vol;
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memProc.running = true;
            cpuProc.running = true;
            volProc.running = true;
            micVolProc.running = true;
        }
    }
    
    Component.onCompleted: {
        memProc.running = true;
        cpuProc.running = true;
        volProc.running = true;
        micVolProc.running = true;
    }
}
