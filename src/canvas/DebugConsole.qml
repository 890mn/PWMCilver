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
        spacing: 6


        RowLayout {
            Layout.fillWidth: true
            height: 68
            spacing: 16

            FluText {
                Layout.fillWidth: true
                text: "🧪 调试终端"
                font.pixelSize: 20
                font.family: smileFont.name
                color: FluTheme.primaryColor
                leftPadding: 12
                Layout.alignment: Qt.AlignVCenter
            }

            // 右侧按钮区
            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                FluButton {
                    text: "Clear"
                    font.pixelSize: 16
                    font.family: smileFont.name
                    implicitWidth: font.pixelSize * text.length * 0.7
                    implicitHeight: parent.height
                    verticalPadding: 6
                    onClicked: {
                        debugText.text = "调试输出：\n"
                        consoleRoot.clearRequested()
                    }
                }

                FluToggleSwitch {
                    Layout.alignment: Qt.AlignVCenter
                    checked: true
                    text: "自动滚动"
                    font.family: smileFont.name
                    font.pixelSize: 16
                    height: parent.height * 0.75
                    rightPadding: 6
                    onCheckedChanged: consoleRoot.autoScroll = checked
                }
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
