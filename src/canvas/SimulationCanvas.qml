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
                let timestamp = now.toLocaleTimeString();
                let log = "[" + timestamp + "] " + message;

                debugConsole.text += log + "\n";

                // 👉 强制光标移到最后
                debugConsole.cursorPosition = debugConsole.text.length;

                // 👉 滚动到底部（尤其适配 Fluent 风格时更稳）
                Qt.callLater(() => {
                    debugConsole.positionViewAtEnd();
                });
            }
        }
    }
}
