import QtQuick 2.15
import QtQuick.Controls 2.15
import FluentUI
import QtQuick.Layouts

Item {
    RowLayout {
        id: bottomRow
        width: bottomSection.width
        height: bottomSection.height

        // 蓝牙连接状态
        Rectangle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
            height: 40
            color: "transparent"
            border.color: "transparent"

            Text {
                text: qsTr("BT: Connected / DX-BT24")
                anchors.centerIn: parent
                font.pixelSize: 20
                font.family: smileFont.name
                color: globalTextColor
            }
        }

        // 小车电量状态
        Rectangle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
            height: 40
            color: "transparent"
            border.color: "transparent"

            Text {
                text: qsTr("Power: 80% / 3.7V 1000mAh")
                anchors.centerIn: parent
                font.pixelSize: 20
                font.family: smileFont.name
                color: globalTextColor
            }
        }

        // 小车主控状态
        Rectangle {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignLeft
            height: 40
            color: "transparent"
            border.color: "transparent"

            Text {
                text: qsTr("MCU: STM32 / PWMC Ver.0.1.0")
                anchors.centerIn: parent
                font.pixelSize: 20
                font.family: smileFont.name
                color: globalTextColor
            }
        }

        // 返回主页按钮
        FluFilledButton {
            text: qsTr("返回主页 / Back")
            font.pixelSize: 22
            font.family: smileFont.name
            height: bottomRow.width * 0.1
            width: bottomRow.width * 0.13
            Layout.alignment: Qt.AlignRight
            Layout.rightMargin: bottomRow.width * 0.02
            onClicked: returnToHome()
        }
    }
}
