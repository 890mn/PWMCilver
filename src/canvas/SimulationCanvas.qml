import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15

Rectangle {
    id: root
    radius: 10
    border.color: "#a0a0a0"
    border.width: 2
    color: "white"

    width: parent.width
    height: parent.height

    property int frontDistance: 21
    property int leftDistance: 91
    property int rightDistance: 23
    property int backDistance: 25
    property int maxDistance: 100

    function getColorByDistance(dist) {
        const ratio = Math.min(1.0, dist / maxDistance)
        const r = Math.floor(255 * (1 - ratio))
        const g = Math.floor(255 * ratio)
        return Qt.rgba(r / 255, g / 255, 0, 0.3)
    }

    // ⬇️ 扇形探测图（位于最底层）
    Canvas {
        id: sensorCanvas
        anchors.fill: parent
        z: 1

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const centerX = width / 2
            const centerY = height / 2

            function drawSector(distance, angleDeg) {
                const angleRad = angleDeg * Math.PI / 180
                const spread = 30 * Math.PI / 180
                const radius = Math.min(distance * 2, width / 2.5)
                ctx.beginPath()
                ctx.moveTo(centerX, centerY)
                ctx.arc(centerX, centerY, radius, angleRad - spread / 2, angleRad + spread / 2)
                ctx.closePath()
                ctx.fillStyle = root.getColorByDistance(distance)
                ctx.fill()
            }

            drawSector(root.frontDistance, 270)
            drawSector(root.backDistance, 90)
            drawSector(root.leftDistance, 180)
            drawSector(root.rightDistance, 0)
        }

        Connections {
            target: root
            function onFrontDistanceChanged() {
                sensorCanvas.requestPaint()
            }
            function onBackDistanceChanged() {
                sensorCanvas.requestPaint()
            }
            function onLeftDistanceChanged() {
                sensorCanvas.requestPaint()
            }
            function onRightDistanceChanged() {
                sensorCanvas.requestPaint()
            }
        }
    }

    // ⬇️ 小车轮廓
    Shape {
        id: carOutline
        width: 120
        height: 120
        anchors.centerIn: parent
        z: 0
        ShapePath {
            strokeWidth: 2
            strokeColor: "#607d8b"
            fillColor: "#e0f7fa"
            startX: 60; startY: 0
            PathLine { x: 120; y: 30 }
            PathLine { x: 120; y: 90 }
            PathLine { x: 60; y: 120 }
            PathLine { x: 0; y: 90 }
            PathLine { x: 0; y: 30 }
            PathLine { x: 60; y: 0 }
        }
    }

    // ⬇️ 中心箭头
    Shape {
        anchors.centerIn: parent
        width: 80
        height: 80
        z: 1
        ShapePath {
            strokeWidth: 2
            strokeColor: "#673ab7"
            fillColor: "#673ab7"
            startX: 40; startY: 10
            PathLine { x: 70; y: 60 }
            PathLine { x: 50; y: 60 }
            PathLine { x: 50; y: 70 }
            PathLine { x: 30; y: 70 }
            PathLine { x: 30; y: 60 }
            PathLine { x: 10; y: 60 }
            PathLine { x: 40; y: 10 }
        }
    }

    // ⬇️ 距离标签
    Text {
        id: frontLabel
        text: "Front: " + root.frontDistance + " cm"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        color: "#ff9800"
    }

    Text {
        id: backLabel
        text: "Back: " + root.backDistance + " cm"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        color: "#ff9800"
    }

    Text {
        id: leftLabel
        text: "Left: " + root.leftDistance + " cm"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        color: "#9c27b0"
    }

    Text {
        id: rightLabel
        text: "Right: " + root.rightDistance + " cm"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        color: "#9c27b0"
    }
}
