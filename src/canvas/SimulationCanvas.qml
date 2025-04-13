import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import "../canvas"

Rectangle {
    id: root
    radius: 10
    border.color: "#a0a0a0"
    border.width: 2
    color: "white"

    width: parent.width
    height: parent.height

    property int frontDis: 0
    property int leftDis: 0
    property int rightDis: 0
    property int backDis: 0

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
        width: parent.width
        height: parent.height
        z: 1

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            const centerX = width / 2
            const centerY = height / 2

            function drawSector(distance, angleDeg) {
                const angleRad = angleDeg * Math.PI / 180
                const spread = 30 * Math.PI / 180
                const radius = distance === -1 ? width / 2.5 : Math.min(distance * 2, width / 2.5)
                ctx.beginPath()
                ctx.moveTo(centerX, centerY)
                ctx.arc(centerX, centerY, radius, angleRad - spread / 2, angleRad + spread / 2)
                ctx.closePath()
                ctx.fillStyle = root.getColorByDistance(distance)
                ctx.fill()
            }

            drawSector(root.frontDis, 270)
            drawSector(root.backDis, 90)
            drawSector(root.leftDis, 180)
            drawSector(root.rightDis, 0)
        }

        Connections {
            target: root
            function onFrontDisChanged() {
                sensorCanvas.requestPaint()
            }
            function onBackDisChanged() {
                sensorCanvas.requestPaint()
            }
            function onLeftDisChanged() {
                sensorCanvas.requestPaint()
            }
            function onRightDisChanged() {
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
        text: "Front: " + root.frontDis + " cm"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 10
        color: "#ff9800"
    }

    Text {
        id: backLabel
        text: "Back: " + root.backDis + " cm"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 10
        color: "#ff9800"
    }

    Text {
        id: leftLabel
        text: "Left: " + root.leftDis + " cm"
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        color: "#9c27b0"
    }

    Text {
        id: rightLabel
        text: "Right: " + root.rightDis + " cm"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        color: "#9c27b0"
    }
}
