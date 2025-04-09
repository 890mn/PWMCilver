import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI

Rectangle {
    id: consoleRoot
    width: 500
    height: 300
    color: "white"
    radius: 8
    border.color: "#a0a0a0"
    border.width: 2

    property alias text: debugText.text
    property alias font: debugText.font
    property bool autoScroll: true

    signal clearRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 4
        //padding: 8

        // 顶部栏（带标题和按钮）
        RowLayout {
            Layout.fillWidth: true

            FluText {
                text: "🧪 调试终端"
                font.pixelSize: 20
                font.family: smileFont.name
                color: FluTheme.primaryColor
                Layout.alignment: Qt.AlignVCenter
            }

            Item { Layout.fillWidth: true }

            FluButton {
                text: "Clear"

                onClicked: {
                    debugText.text = "调试输出：\n"
                    consoleRoot.clearRequested()
                }
            }

            FluToggleSwitch {
                checked: true
                text: "自动滚动"
                onCheckedChanged: consoleRoot.autoScroll = checked
            }
        }

        // 滚动显示区域
        Flickable {
            id: flickArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: debugText.paintedWidth
            contentHeight: debugText.paintedHeight
            clip: true
            interactive: true

            Text {
                id: debugText
                text: "调试输出：\n"
                wrapMode: Text.Wrap
                width: flickArea.width
                font.family: smileFont.name
                font.pixelSize: 18
            }
        }
    }

    function appendMessage(msg) {
        let now = new Date();
        let timestamp = now.toLocaleTimeString();
        debugText.text += "[" + timestamp + "] " + msg + "\n";

        if (autoScroll) {
            Qt.callLater(() => {
                flickArea.contentY = flickArea.contentHeight - flickArea.height;
            });
        }
    }
}
