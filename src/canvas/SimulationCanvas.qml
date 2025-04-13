import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import FluentUI
import "../simulation"
import "../section"

Rectangle {
    id: root
    width: parent.width
    height: parent.height
    color: "white"
    radius: 10
    border.color: "#a0a0a0"
    border.width: 2

    // 标题
    FluText {
        x: 7
        y: 7
        text: "🕹️ 平面图"
        font.pixelSize: 20
        font.family: smileFont.name
        color: FluTheme.primaryColor
    }

    CarBody {
        id: carBody
        anchors.centerIn: parent
    }

    SensorRect {
        id: frontSensor
        direction: "front"
        x: carBody.x + carBody.width / 2 - width / 2
        y: carBody.y - height
    }

    SensorRect {
        id: backSensor
        direction: "back"
        x: carBody.x + carBody.width / 2 - width / 2
        y: carBody.y + carBody.height
    }

    SensorRect {
        id: leftSensor
        direction: "left"
        x: carBody.x - width
        y: carBody.y + carBody.height / 2 - height / 2
    }

    SensorRect {
        id: rightSensor
        direction: "right"
        x: carBody.x + carBody.width
        y: carBody.y + carBody.height / 2 - height / 2
    }

    // 车轮
    Repeater {
        model: 4
        Wheel {
            index: model.index
            centerX: carBody.x + carBody.width / 2
            centerY: carBody.y + carBody.height / 2
        }
    }
/*
    // 🧭 四方向距离文本（绑定 DebugConsole 中的属性）
    Text {
        text: simulationCanvas.frontDis + " cm"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -20
        anchors.top: parent.top
        anchors.topMargin: 135
        font.pixelSize: 16
        color: "#3a3a3a"
    }

    Text {
        text: simulationCanvas.backDis + " cm"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: 20
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 135
        font.pixelSize: 16
        color: "#3a3a3a"
    }

    Text {
        text: simulationCanvas.leftDis + " cm"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 20
        anchors.left: parent.left
        anchors.leftMargin: 180
        font.pixelSize: 16
        color: "#3a3a3a"
    }

    Text {
        text: simulationCanvas.rightDis + " cm"
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -20
        anchors.right: parent.right
        anchors.rightMargin: 180
        font.pixelSize: 16
        color: "#3a3a3a"
    }
*/
    Canvas {
        id: sensorCanvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            function getColor(dist) {
                const ratio = Math.min(1.0, dist / maxDistance)
                const r = Math.floor(255 * (1 - ratio))
                const g = Math.floor(255 * ratio)
                return `rgba(${r},${g},0,0.5)`
            }

            function drawSensorLine(distance, angleDeg, sensorX, sensorY) {
                const angleRad = angleDeg * Math.PI / 180
                const dx = Math.cos(angleRad)
                const dy = Math.sin(angleRad)

                const capAngle = angleRad + Math.PI / 2
                const capDx = Math.cos(capAngle)
                const capDy = Math.sin(capAngle)

                const offset = 10  // 起始偏移，让它在模块外
                const length = maxDistance

                const startX = sensorX + dx * offset
                const startY = sensorY + dy * offset
                const endX = startX + dx * length
                const endY = startY + dy * length

                const capLength = Math.abs(startX - endX) * 0.3 + Math.abs(startY - endY) * 0.3 // 横杠长度

                ctx.strokeStyle = getColor(distance)
                ctx.lineWidth = 6

                ctx.beginPath()

                // 起始横杠（横向）
                ctx.moveTo(startX + capDx * capLength, startY + capDy * capLength)
                ctx.lineTo(startX, startY)

                // 主线
                ctx.lineTo(endX, endY)

                // 终点横杠（横向）
                ctx.lineTo(endX + capDx * capLength, endY + capDy * capLength)

                ctx.stroke()
            }

            drawSensorLine(simulationCanvas.frontDis, 270, frontSensor.x + 3, frontSensor.y + frontSensor.height - 5)
            drawSensorLine(simulationCanvas.rightDis, 0, rightSensor.x + 5, rightSensor.y + 3)
            drawSensorLine(simulationCanvas.backDis, 90, backSensor.x  - 3 + backSensor.width, backSensor.y + 5)
            drawSensorLine(simulationCanvas.leftDis, 180, leftSensor.x + leftSensor.width - 5, leftSensor.y + leftSensor.height - 3)
        }

        Connections {
            target: simulationCanvas
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
}
