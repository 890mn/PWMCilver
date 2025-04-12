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

                    function onUltrasonicDataUpdated(left, front, right, back) {
                        debugConsole.leftDistance = left
                        debugConsole.frontDistance = front
                        debugConsole.rightDistance = right
                        debugConsole.backDistance = back

                        simulationCanvas.leftDis = left
                        simulationCanvas.frontDis = front
                        simulationCanvas.rightDis = right
                        simulationCanvas.backDis = back
                    }

                    function onMotorCommandReceived(id, pwm, time) {
                        console.log("电机指令 => ID:", id, "PWM:", pwm, "Time:", time)

                        debugConsole.appendMessage(`电机 #${id} => PWM: ${pwm}, Time: ${time}`)
                        debugConsole.motorData[id]["pwm"] = pwm
                        debugConsole.motorData[id]["time"] = time

                        function pwmToDir(pwm) {
                            if (pwm > 1500) return "正";
                            if (pwm < 1500) return "反";
                            return "停";
                        }

                        let fl = pwmToDir(debugConsole.motorData["006"].pwm)
                        let fr = pwmToDir(debugConsole.motorData["007"].pwm)
                        let bl = pwmToDir(debugConsole.motorData["008"].pwm)
                        let br = pwmToDir(debugConsole.motorData["009"].pwm)

                        let motion = "未知"

                        if (fl === "正" && fr === "反" && bl === "正" && br === "反") {
                            motion = "前进"
                        } else if (fl === "反" && fr === "正" && bl === "反" && br === "正") {
                            motion = "后退"
                        } else if (fl === "反" && fr === "反" && bl === "正" && br === "正") {
                            motion = "左转"
                        } else if (fl === "正" && fr === "正" && bl === "反" && br === "反") {
                            motion = "右转"
                        } else if (fl === "停" && fr === "停" && bl === "停" && br === "停") {
                            motion = "停止"
                        }

                        debugConsole.currentMotion = motion
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
