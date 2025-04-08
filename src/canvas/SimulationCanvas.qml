import QtQuick 2.15
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

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d");
            ctx.clearRect(0, 0, width, height); // 清空画布
        }
    }
}
