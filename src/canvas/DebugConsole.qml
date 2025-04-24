import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI

Rectangle {
    id: consoleRoot
    width: debugConsole.width
    height: debugConsole.height
    color: "white"
    radius: 8
    border.color: "#a0a0a0"
    border.width: 2

    property int leftDistance: 0
    property int frontDistance: 0
    property int rightDistance: 0
    property int backDistance: 0
    property string currentMotion: "IDLE"
    property bool autoScroll: true

    property string lastChassisInfo: ""

    signal clearRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Item { Layout.preferredWidth: 4 }

        // 顶部标题栏
        RowLayout {
            Layout.fillWidth: true
            height: 60
            spacing: 16

            FluText {
                Layout.fillWidth: true
                text: "🧪 调试终端"
                font.pixelSize: 20
                font.family: smileFont.name
                color: FluTheme.primaryColor
                leftPadding: 6
                Layout.alignment: Qt.AlignVCenter
            }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                FluToggleSwitch {
                    Layout.alignment: Qt.AlignVCenter
                    checked: true
                    height: parent.height * 0.75
                    onCheckedChanged: consoleRoot.autoScroll = checked
                }

                FluButton {
                    text: "Clear"
                    font.pixelSize: 16
                    normalColor: colorWhite
                    hoverColor: colorWhiteHover
                    //textColor: colorPink
                    implicitWidth: font.pixelSize * text.length * 0.65
                    implicitHeight: font.pixelSize * 1.3
                    onClicked: {
                        avoidText.text = ""
                        avoidArea.clearRequested()
                    }
                }

                Item { Layout.preferredWidth: 4 }
            }
        }

        ColumnLayout {
            spacing: 4
            width: debugConsole.width - 15  // 控制宽度为整个窗口宽度的90%
            Layout.preferredHeight: (consoleRoot.height) / 3
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 15

            FluText {
                text: "🛞 底盘信息"
                font.pixelSize: 18
                font.family: smileFont.name
                color: "#444"
            }

            ColumnLayout {
                id: chassisInfoBox
                spacing: 4
                width: parent.width - 10

                Row {
                    spacing: 10
                    FluText {
                        text: "执行方向:"
                        font.pixelSize: 17
                        font.family: smileFont.name
                        color: "#217aff"
                    }
                    FluText {
                        id: directionLabel
                        text: "-"
                        font.pixelSize: 17
                        font.family: smileFont.name
                        color: "#333"
                    }
                    FluText {
                        text: "估算时间:"
                        font.pixelSize: 17
                        font.family: smileFont.name
                        color: "#217aff"
                    }
                    FluText {
                        id: timeLabel
                        text: "-"
                        font.pixelSize: 17
                        font.family: smileFont.name
                        color: "#555"
                    }
                }

                FluText {
                    id: pwmCommandLabel
                    text: ""
                    wrapMode: Text.Wrap
                    width: parent.width
                    font.pixelSize: 15
                    font.family: smileFont.name
                    color: "#888"
                }
            }
        }

        // 📡 避障信息部分
        ColumnLayout {
            width: debugConsole.width - 15  // 控制宽度为整个窗口宽度的90%
            Layout.preferredHeight: (consoleRoot.height) / 3
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            FluText {
                text: "📡 避障信息"
                font.pixelSize: 18
                font.family: smileFont.name
                color: "#444"
            }

            Flickable {
                id: avoidArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                interactive: true
                contentWidth: avoidText.paintedWidth
                contentHeight: avoidText.paintedHeight

                Text {
                    id: avoidText
                    x: 10
                    text: ""
                    wrapMode: Text.Wrap
                    width: avoidArea.width - 6
                    horizontalAlignment: Text.AlignLeft
                    font.family: smileFont.name
                    font.pixelSize: 17
                    textFormat: Text.RichText
                }
            }
        }

        // 底部调试输入栏
        RowLayout {
            Layout.fillWidth: true
            height: 60
            spacing: 16
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: 11

            FluTextBox {
                id: sendInput
                placeholderText: "调试指令由此输入:"
                width: parent.width / 3
            }

            Timer {
                id: sendThrottle
                interval: 100
                repeat: false
                onTriggered: {
                    BLE.sendMessage(sendInput.text)
                }
            }

            FluFilledButton {
                text: "发送"
                onClicked: {
                    if (!sendThrottle.running)
                        sendThrottle.start()
                }
            }
        }
        Item { Layout.preferredWidth: 4 }
    }

    // 高亮标签 + 内容追加函数
    function colorText(txt, color) {
        return "<font color='" + color + "'>" + txt + "</font>";
    }

    function appendLine(targetTextObj, msg) {
        targetTextObj.text += msg
        if (consoleRoot.autoScroll) {
            Qt.callLater(() => {
                let flickable = avoidArea
                flickable.contentY = flickable.contentHeight - flickable.height - 25
            })
        }
    }

    function formatMessage(msg, type) {
        let now = new Date()
        let time = now.toLocaleTimeString()
        let tagColor = (type === "chassis") ? "#33ccff" : "orange"
        return `<font color='${tagColor}'>[${time}] [${type === "chassis" ? "底盘" : "避障"}]</font> <font color='#666'>${msg}</font><br>`
    }

    function appendChassis(msg) {
        // 如果是“执行方向”的部分
        if (msg.includes("执行")) {
            lastChassisInfo = msg
            return
        }

        // 如果是 PWM 指令部分，拼接上上次的执行信息
        if (msg.includes("{#")) {
            let combined = lastChassisInfo + "\n" + msg
            lastChassisInfo = "" // 清空缓存，避免残留
            handleFullChassisMessage(combined)
            return
        }

        // 其它非结构化内容 fallback 处理
        directionLabel.text = "-"
        timeLabel.text = "-"
        pwmCommandLabel.text = msg
    }

    // 提取核心内容的处理函数（支持完整结构的消息）
    function handleFullChassisMessage(msg) {
        const regex = /执行\s+(\d+)\s+估算时间=([-\d]+)ms[\s\n]*({[^}]+})?/;
        const match = msg.match(regex)

        if (match) {
            let directionCode = parseInt(match[1])
            let execTime = match[2]
            let commandSet = match[3] || "-"

            const directionMap = [
                "停止", "前进", "后退", "左转", "右转",
                "左前", "右前", "右中", "右中后",
                "左中", "左中后"
            ]
            let directionName = directionMap[directionCode] || `未知(${directionCode})`

            directionLabel.text = directionName
            timeLabel.text = execTime + " ms"
            pwmCommandLabel.text = commandSet
        } else {
            directionLabel.text = "-"
            timeLabel.text = "-"
            pwmCommandLabel.text = msg
        }
    }

    function appendAvoid(msg) {
        const regex = /\s*执行方向=(\d+)\s+距离=(\d+)\s+时间=(\d+ms)/;
        const match = msg.match(regex)
        if (match) {
            const directionMap = [
                "停止", "前进", "后退", "左转", "右转",
                "左前", "右前", "右中", "右中后",
                "左中", "左中后"
            ]

            let dirNum = parseInt(match[1])
            let directionText = directionMap[dirNum] || `未知(${dirNum})`
            let distance = match[2]
            let time = match[3]

            let newMsg = `[避障] 执行方向=${directionText} 距离=${distance} 时间=${time}`
            let formatted = formatMessage(newMsg, "avoid")
            appendLine(avoidText, formatted)
        } else {
            // 非结构化避障信息走原来的路径
            let formatted = formatMessage(msg, "avoid")
            appendLine(avoidText, formatted)
        }
    }
}
