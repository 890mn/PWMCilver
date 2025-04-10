import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI
import QtQuick.Layouts

Rectangle {
    id: controlRoot
    width: controlPanel.width
    height: controlPanel.height
    color: "white"
    radius: 8
    border.color: "#a0a0a0"
    border.width: 2

    // 标题
    FluText {
        x: 7
        y: 7
        text: "🧠 逻辑核心"
        font.pixelSize: 20
        font.family: smileFont.name
        color: FluTheme.primaryColor
        Layout.alignment: Qt.AlignLeft
    }

    ColumnLayout {
        spacing: 6
        anchors.fill: parent

        Item {
            Layout.preferredHeight: 9  // ✅ 下沉高度
        }

        // 测距显示区域
        GridLayout {
            columns: 5
            columnSpacing: 16
            rowSpacing: 2
            Layout.alignment: Qt.AlignHCenter

            FluText { text: "Front:"; font.pixelSize: 18 }
            FluText { text: "Left:"; font.pixelSize: 18 }
            FluText { text: "Right:"; font.pixelSize: 18 }
            FluText { text: "Back:"; font.pixelSize: 18 }
            FluText { text: "Goal:"; font.pixelSize: 18 }

            FluText { text: "123 cm"; font.pixelSize: 18 }
            FluText { text: "124 cm"; font.pixelSize: 18 }
            FluText { text: "125 cm"; font.pixelSize: 18 }
            FluText { text: "126 cm"; font.pixelSize: 18 }
            FluText { text: "200 cm"; font.pixelSize: 18 }
        }

        // 当前状态显示
        FluText {
            text: "Current:"
            font.pixelSize: 20
            font.family: smileFont.name
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 10
        }

        // 控制命令区（Direction + Distance）
        RowLayout {
            spacing: 15
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 10

            FluText {
                text: "Command:"
                font.pixelSize: 20
                font.family: smileFont.name
            }

            FluComboBox {
                id: directionSelector
                Layout.topMargin: 5
                width: 80
                model: ["Forward", "Backward", "Left", "Right"]
            }

            FluComboBox {
                id: distanceSelector
                Layout.topMargin: 5
                width: 80
                model: ["10 cm", "20 cm", "50 cm", "100 cm"]
            }
        }

        // 操作按钮区
        RowLayout {
            spacing: 20
            Layout.alignment: Qt.AlignHCenter

            FluButton {
                text: "紧急制动/Stop"
                font.pixelSize: 22
                font.family: smileFont.name

                normalColor: colorWhite
                hoverColor: colorWhiteHover
                textColor: colorPinkHover

                implicitWidth: font.pixelSize * text.length * 0.75
                implicitHeight: font.pixelSize * 1.7

                onClicked: {
                    // 停止命令
                }
            }

            FluFilledButton {
                text: "发送指令/Send"

                font.pixelSize: 22
                font.family: smileFont.name

                normalColor: colorWhite
                hoverColor: colorWhiteHover
                textColor: colorBlueHover

                implicitWidth: font.pixelSize * text.length * 0.75
                implicitHeight: font.pixelSize * 1.7

                onClicked: {
                    // 发送控制命令
                    let dir = directionSelector.currentText
                    let dis = distanceSelector.currentText
                    console.log("指令已发送：", dir, dis)
                }
            }
        }
    }
}
