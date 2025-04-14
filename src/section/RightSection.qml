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

                    function onCurrentMotionChanged() {
                        debugConsole.currentMotion = BLE.currentMotion
                    }

                    function onUltrasonicSingleUpdated(dir, value) {
                        switch (dir) {
                        case 1:
                            debugConsole.leftDistance = value;
                            simulationCanvas.leftDis = value;
                            break;
                        case 2:
                            debugConsole.frontDistance = value;
                            simulationCanvas.frontDis = value;
                            break;
                        case 3:
                            debugConsole.rightDistance = value;
                            simulationCanvas.rightDis = value;
                            break;
                        case 4:
                            debugConsole.backDistance = value;
                            simulationCanvas.backDis = value;
                            break;
                        }
                    }
                }
            }
        }

        // Control
        Rectangle {
            id: controlRect
            width: parent.width - 20
            height: rightArea.height - debugRect.height - 10
            radius: 10
            border.color: "#a0a0a0"
            color: "white"

            ControlPanel {
                id: controlPanel
                width: parent.width - 4
                height: parent.height - 4
                anchors.centerIn: parent
            }
        }
    }
}
