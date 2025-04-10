import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI
import QtQuick.Layouts
import "../canvas"

ScrollView {
    id: rightSection
    clip: true
    ScrollBar.horizontal.policy: initialLayout.horOn ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
    ScrollBar.vertical.policy: initialLayout.verOn ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

    ColumnLayout {
        id: rightContent
        width: rightSection.width
        spacing: 10

        // Debug
        Rectangle {
            id: debugRect
            width: parent.width - 20
            height: 225
            radius: 10
            border.color: "#a0a0a0"
            color: "white"

            DebugConsole {
                id: debugConsole
                width: parent.width - 4
                height: parent.height - 4
                anchors.centerIn: parent

                Connections {
                    target: BLE
                    function onMessageReceived(message) {
                        debugConsole.appendMessage(message)
                    }
                }
            }
        }

        // Control
        Rectangle {
            id: controlRect
            width: parent.width - 20
            height: rightArea.height - 235
            radius: 10
            border.color: "#a0a0a0"
            color: "white"

            ControlPanel {
                id: controlPanel
                anchors.horizontalCenter: parent.horizontalCenter

                onApplyCommand: (dir, dis) => {
                    console.log("发送指令：", dir, dis)
                    // 调用蓝牙发送函数
                }

                onStopCommand: {
                    console.log("急停指令已发出")
                    // 调用 STOP 相关函数
                }

                // 🚨 实时更新 currentStatus 显示内容
                Component.onCompleted: {
                    currentStatus = "Waiting..."
                }
            }
        }
    }
}
