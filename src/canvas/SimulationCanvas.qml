import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI

Rectangle {
    id: simulationCanvas
    radius: 10
    border.color: "#a0a0a0"
    border.width: 2
    color: "white"

    property real maxX: 600 // 最大 X 轴刻度
    property real maxY: 400 // 最大 Y 轴刻度

    property real rectWidth: 500 // 矩形宽度
    property real rectHeight: 300 // 矩形高度

    TextArea {
        id: debugConsole
        anchors.fill: parent
        readOnly: true
        text: "调试输出：\n"
        font.family: smileFont.name
        font.pixelSize: 21

        Connections {
            target: BLE
            function onMessageReceived(message) {
                let now = new Date();
                let timestamp = now.toLocaleTimeString(); // 输出形如 "14:35:08"
                let log = "[" + timestamp + "] " + message;

                console.log("QML 收到数据:", log);
                debugConsole.text += log + "\n";
                debugConsole.cursorPosition = debugConsole.length; // 自动滚动到底
            }
        }
    }
}
