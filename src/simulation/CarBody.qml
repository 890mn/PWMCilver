import QtQuick 2.15
import QtQuick.Shapes 1.15

Item {
    id: body
    width: 220
    height: 220

    property real r: 110
    property real cx: 110
    property real cy: 110

    Shape {
        anchors.fill: parent
        ShapePath {
            strokeWidth: 4
            strokeColor: "#888"
            fillColor: "transparent"

            startX: cx + r * Math.cos(Math.PI / 8)
            startY: cy + r * Math.sin(Math.PI / 8)

            // 八边形路径
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 3); y: cy + r * Math.sin(Math.PI / 8 * 3) }
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 5); y: cy + r * Math.sin(Math.PI / 8 * 5) }
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 7); y: cy + r * Math.sin(Math.PI / 8 * 7) }
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 9); y: cy + r * Math.sin(Math.PI / 8 * 9) }
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 11); y: cy + r * Math.sin(Math.PI / 8 * 11) }
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 13); y: cy + r * Math.sin(Math.PI / 8 * 13) }
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 15); y: cy + r * Math.sin(Math.PI / 8 * 15) }
            PathLine { x: cx + r * Math.cos(Math.PI / 8 * 1); y: cy + r * Math.sin(Math.PI / 8 * 1)}
        }
    }

    Image {
        source: "qrc:/asset/arrow_pngtree.png"
        width: 100; height: 100
        anchors.centerIn: parent
    }
}
