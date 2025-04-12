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

    property int leftDistance: -1
    property int frontDistance: -1
    property int rightDistance: -1
    property int backDistance: -1

    property var motorData: ({
        "006": { pwm: 1500, time: 0 },
        "007": { pwm: 1500, time: 0 },
        "008": { pwm: 1500, time: 0 },
        "009": { pwm: 1500, time: 0 }
    })
    property string currentMotion: "Unknown"

    property alias text: debugText.text
    property alias font: debugText.font
    property bool autoScroll: true

    signal clearRequested()

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Item { Layout.preferredHeight: 4 }

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
                    textColor: colorPink
                    implicitWidth: font.pixelSize * text.length * 0.65
                    implicitHeight: font.pixelSize * 1.3

                    onClicked: {
                        debugText.text = "调试输出：\n"
                        consoleRoot.clearRequested()
                    }
                }

                Item { Layout.preferredWidth: 4 }
            }
        }

        Flickable {
            id: flickArea
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            interactive: true
            contentWidth: debugText.paintedWidth
            contentHeight: debugText.paintedHeight

            Text {
                id: debugText
                x: 6
                text: "调试输出：\n"
                wrapMode: Text.Wrap
                width: flickArea.width - 6
                horizontalAlignment: Text.AlignLeft
                font.family: smileFont.name
                font.pixelSize: 18
            }
        }

        Item { Layout.preferredHeight: 2 }
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
