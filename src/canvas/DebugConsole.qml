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
                        chassisText.text = ""
                        avoidText.text = ""
                        consoleRoot.clearRequested()
                    }
                }

                Item { Layout.preferredWidth: 4 }
            }
        }

        ColumnLayout {
            spacing: 4
            width: debugConsole.width - 15  // 控制宽度为整个窗口宽度的90%
            Layout.preferredHeight: (consoleRoot.height) / 3
            Layout.alignment: Qt.AlignHCenter

            FluText {
                text: "🛞 底盘信息"
                font.pixelSize: 18
                font.family: smileFont.name
                color: "#444"
            }

            Flickable {
                id: chassisArea
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                interactive: true
                contentWidth: chassisText.paintedWidth
                contentHeight: chassisText.paintedHeight

                Text {
                    id: chassisText
                    x: 10
                    text: ""
                    wrapMode: Text.Wrap
                    width: chassisArea.width - 6
                    height: parent.height
                    horizontalAlignment: Text.AlignLeft
                    font.family: smileFont.name
                    font.pixelSize: 17
                    textFormat: Text.RichText
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
        if (targetTextObj === chassisText) {
            targetTextObj.text += msg + "<br>"
        } else {
            targetTextObj.text += msg
        }
        if (consoleRoot.autoScroll) {
            Qt.callLater(() => {
                let flickable = (targetTextObj === chassisText) ? chassisArea : avoidArea
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
        let now = new Date();
        let timestamp = now.toLocaleTimeString();

        const regex = /执行\s+(\d+)\s+估算时间=([-\d]+)ms[\s\n]*({[^}]+})/;
        const match = msg.match(regex);

        if (match) {
            let directionCode = parseInt(match[1]);
            let execTime = match[2];
            let commandSet = match[3];

            const directionMap = [
                "停止", "前进", "后退", "左转", "右转",
                "左前", "右前", "右中", "右中后",
                "左中", "左中后"
            ];
            let directionName = directionMap[directionCode] || `未知(${directionCode})`;

            let formattedText =
                colorText("[" + timestamp + "]", "#666") + " " +
                colorText("[底盘]", "#217aff") + " " +
                colorText(directionName, "#000") +
                " | 估算时间: " + colorText(execTime + "ms", "#888");

            appendLine(chassisText, formattedText)
            appendLine(chassisText, colorText(commandSet, "#999"))

        } else {
            let fallbackText =
                colorText("[" + timestamp + "]", "#666") + " " +
                colorText("[底盘]", "#217aff") + " " +
                colorText(msg, "#666");
            appendLine(chassisText, fallbackText)
        }
    }

    function appendAvoid(msg) {
        let formatted = formatMessage(msg, "avoid")
        appendLine(avoidText, formatted)
    }
}
