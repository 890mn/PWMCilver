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

    Column {
        id: rightContent
        width: rightSection.width
        height: rightArea.height
        spacing: 10

        // Debug
        Rectangle {
            id: debugRect
            width: parent.width - 20
            height: topSection.height * 0.45
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
                        let buffer = message;
                        let parts = [];
                        let temp = "";
                        let insideBraces = false;

                        for (let i = 0; i < buffer.length; ++i) {
                            let cha = buffer[i];

                            if (cha === '{') {
                                insideBraces = true;
                            } else if (cha === '}') {
                                insideBraces = false;
                            }

                            temp += cha;

                            if (cha === '\n' && !insideBraces) {
                                parts.push(temp.trim());
                                temp = "";
                            }
                        }

                        if (temp.length > 0) {
                            parts.push(temp.trim());
                        }

                        for (let line of parts) {
                            let pureMsg = line;
                            let type = "unknown";

                            if (line.startsWith("[底盘]")) {
                                pureMsg = line.slice(4).trim();
                                type = "chassis";
                            } else if (line.startsWith("[避障]")) {
                                pureMsg = line.slice(4).trim();
                                type = "avoid";
                            } else if (line.includes("估算时间")) {
                                type = "chassis";
                            } else if (line.includes("障碍") || line.includes("推理")) {
                                type = "avoid";
                            } else if (line.includes("{#00")) {
                                type = "chassis";
                            }

                            if (type === "chassis") {
                                debugConsole.appendChassis(pureMsg);
                            } else if (type === "avoid") {
                                debugConsole.appendAvoid(pureMsg);
                            }
                        }
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
            height: topSection.height * 0.55 - 10
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
