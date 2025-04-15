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

    property bool canUpdate: true

    function throttledPaint() {
        if (canUpdate) {
            sensorCanvas.requestPaint()
            canUpdate = false
            Qt.callLater(function() {
                canUpdate = true
            })
        }
    }

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

    // 🧭 四方向距离文本（绑定 DebugConsole 中的属性）
    Text {
        text: simulationCanvas.frontDis + " cm"
        font.family: smileFont.name
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 30
        anchors.leftMargin: 10
        font.pixelSize: 18
        color: "#3a3a3a"
    }

    Text {
        text: simulationCanvas.backDis + " cm"
        font.family: smileFont.name
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 30
        anchors.rightMargin: 10
        font.pixelSize: 18
        color: "#3a3a3a"
    }

    Text {
        text: simulationCanvas.leftDis + " cm"
        font.family: smileFont.name
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 18
        anchors.left: parent.left
        anchors.leftMargin: 93
        font.pixelSize: 18
        color: "#3a3a3a"
    }

    Text {
        text: simulationCanvas.rightDis + " cm"
        font.family: smileFont.name
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -18
        anchors.right: parent.right
        anchors.rightMargin: 93
        font.pixelSize: 18
        color: "#3a3a3a"
    }

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

                const capLength = Math.abs(startX - endX) * 0.2 + Math.abs(startY - endY) * 0.2 // 横杠长度

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
                throttledPaint()
            }
            function onBackDisChanged() {
                throttledPaint()
            }
            function onLeftDisChanged() {
                throttledPaint()
            }
            function onRightDisChanged() {
                throttledPaint()
            }
        }
    }

    // 右下角图例 Legend
    Rectangle {
        id: legendBox
        width: 200
        height: 50
        radius: 8
        color: "transparent"
        border.color: "#b0b0b0"
        border.width: 1
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.rightMargin: 10
        anchors.bottomMargin: 10

        Column {
            anchors.fill: parent
            anchors.margins: 8
            anchors.topMargin: 12
            spacing: 4

            Rectangle {
                id: gradientBar
                width: parent.width - 16
                height: 12
                radius: 6
                anchors.horizontalCenter: parent.horizontalCenter
                layer.enabled: true
                layer.smooth: true

                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#EA1F1F" }   // 红
                    GradientStop { position: 0.5; color: "#EABE1F" }   // 橙
                    GradientStop { position: 1.0; color: "#5CEA1F" }   // 绿
                }
            }

            Row {
                id: scaleLabels
                spacing: (gradientBar.width - 3 * 20) / 2  // 自动分配空间
                anchors.horizontalCenter: parent.horizontalCenter
                width: gradientBar.width
                height: 20

                Repeater {
                    model: ["0cm", "50cm", "100cm"]
                    Text {
                        text: modelData
                        font.pixelSize: 11
                        color: "#505050"
                        font.family: smileFont.name
                        horizontalAlignment: Text.AlignHCenter
                        width: 20
                    }
                }
            }
        }
    }
}
