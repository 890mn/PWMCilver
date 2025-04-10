import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI
import QtQuick.Layouts

Item {
    id: root
    width: 500
    height: 180

    // 👇 向外暴露的属性
    property string currentStatus: "Idle"
    property alias selectedDirection: dirSelector.currentText
    property alias selectedDistance: distanceInput.value

    // 👇 提供两个信号，供主页面连接
    signal applyCommand(string dir, int dis)
    signal stopCommand()

    ColumnLayout {
        anchors.fill: parent
        spacing: 18
        anchors.margins: 10

        // 当前状态
        Rectangle {
            width: parent.width
            height: 44
            radius: 6
            color: "#f0f0f0"
            border.color: "#cccccc"

            Text {
                text: "Current: " + root.currentStatus
                anchors.centerIn: parent
                font.pixelSize: 20
                font.family: smileFont.name
                color: "#333"
            }
        }

        // 控制区域
        RowLayout {
            spacing: 20

            // Direction
            Column {
                spacing: 4
                Text {
                    text: "Direction:"
                    font.pixelSize: 16
                    font.family: smileFont.name
                    color: globalTextColor
                }
                ComboBox {
                    id: dirSelector
                    width: 130
                    model: ["Forward", "Backward", "Left", "Right", "Left-Forward", "Right-Forward"]
                }
            }

            // Distance
            Column {
                spacing: 4
                Text {
                    text: "Distance (cm):"
                    font.pixelSize: 16
                    font.family: smileFont.name
                    color: globalTextColor
                }
                SpinBox {
                    id: distanceInput
                    from: 0
                    to: 500
                    value: 50
                    stepSize: 10
                    width: 100
                }
            }

            // Apply
            FluFilledButton {
                text: "Apply"
                font.pixelSize: 18
                onClicked: root.applyCommand(dirSelector.currentText, distanceInput.value)
            }

            // Stop
            FluFilledButton {
                text: "Stop"
                font.pixelSize: 18
                onClicked: root.stopCommand()
            }
        }
    }
}
