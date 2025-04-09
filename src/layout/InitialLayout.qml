import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15
import FluentUI 1.0

Item {
    id: initalLayout
    signal startSimulation()

    property bool horOn: false
    property bool verOn: false

    property int maxLight: 8
    property int maxSensor: 8

    property bool bthLinked: true
    property bool bthLoading: false

    Rectangle {
        width: parent.width
        height: 230
        opacity: 0.8
        color: Qt.rgba(85/255,120/255,155/255,195/255)
        radius: 8
        anchors.centerIn: parent
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 20
        y: 20
        spacing: 10

        FluFilledButton {
            text: qsTr("环境设置 / Setting")
            font.pixelSize: mainWindow.height / 28
            font.family: smileFont.name
            implicitWidth: font.pixelSize * text.length * 0.55
            implicitHeight: font.pixelSize * 1.7
            onClicked: {
                sheet.open(FluSheetType.Top)
            }
        }
        FluFilledButton {
            text: qsTr("更新说明 / Update Info")
            font.pixelSize: mainWindow.height / 28
            font.family: smileFont.name
            implicitWidth: font.pixelSize * text.length * 0.5
            implicitHeight: font.pixelSize * 1.7
            onClicked: {
                noUpdateDialog.open()
            }
        }
        FluContentDialog {
            id: noUpdateDialog
            title:  qsTr("PWMCilver")
            message: "Thanks to FluentUI/Smiley Sans which uses in this Project."

            onPositiveClicked: {
                Qt.openUrlExternally("https://github.com/890mn/PWMCilver/releases");
            }
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        spacing: 140

        Column {
            id: mainState
            spacing: 15
            opacity: 1

            FluText {
                text: qsTr("平面建模定位系统")
                color: colorGreen
                font.pixelSize: mainWindow.height / 10
                font.family: smileFont.name
            }

            Row {
                x: 100

                FluText {
                    text: qsTr("避障反馈调控平台 |")
                    color: colorPink
                    font.pixelSize: mainWindow.height / 17
                    font.family: smileFont.name
                }
                FluText {
                    anchors.bottom: parent.bottom
                    text: qsTr(" Powered By Qt6")
                    color: globalTextColor
                    font.pixelSize: mainWindow.height / 21
                    font.family: smileFont.name
                }
            }
        }

        Column {
            id: buttonRow
            spacing: 15
            y: 5

            FluButton {
                id: blutoothButton
                text: qsTr("❮ 链接设备 / BthLink")

                normalColor: colorWhite
                hoverColor: colorWhiteHover
                textColor: colorPink

                font.pixelSize: mainWindow.height / 20
                font.family: smileFont.name
                implicitWidth: font.pixelSize * text.length * 0.5
                implicitHeight: font.pixelSize * 1.67

                onClicked: {
                    if (!bthLinked) {
                        bthLoading = true // ✅ 开始加载
                        BLE.connectToTargetDevice()
                    } else {
                        bthLoading = false // ✅ 已连接/断开时隐藏
                    }
                }

                Connections {
                    target: BLE
                    function onConnectedChanged() {
                        bthLinked = BLE.connected
                        blutoothButton.textColor = bthLinked ? colorGray : colorPink
                    }
                }
            }

            FluProgressBar {
                id: bleLoadingBar
                //anchors.centerIn: parent
                width: 200
                visible: bthLoading
                //indeterminate: false
                strokeWidth: 6
                progressVisible: true
            }

            FluButton {
                id: startSimButton
                text: qsTr("❯ Start")
                normalColor: colorWhite
                hoverColor: colorWhiteHover
                disableColor: Qt.rgba(85/255,120/255,155/255,0/255)
                textColor: bthLinked ? colorPink : colorWhite

                font.pixelSize: mainWindow.height / 22
                font.family: smileFont.name
                implicitWidth: font.pixelSize * text.length * 0.47
                implicitHeight: font.pixelSize * 1.67

                enabled: bthLinked
                onClicked: {
                    startSimulation()
                }
            }
        }
    }

    Row {
        anchors{
            bottom: parent.bottom
            bottomMargin: 10
            right: parent.right
        }
        FluText{
            font.pixelSize: mainWindow.height / 30
            color: globalTextColor
            font.family: smileFont.name
            font.bold: true
            text: qsTr("愿你在上位机的世界沐浴五束阳光 |")
        }
        FluText{
            font.pixelSize: mainWindow.height / 30
            font.family: smileFont.name
            font.bold: true
            text: " PWMC-DisDection.0.1"
            color: Qt.rgba(87/255,151/255,180/255,255/255)
        }
        FluText{
            y: 3
            font.pixelSize: mainWindow.height / 35
            font.family: brushFont.name
            font.bold: true
            text: " Release "
            color: Qt.rgba(87/255,151/255,180/255,255/255)
        }
    }

    FluSheet {
        id:sheet
        size: 450 // Height

        Column {
            width: parent.width
            height: parent.height

            spacing: 10
            padding: 10

            // Global
            FluText {
                y: 10
                text: qsTr("软件环境设置")
                font.family: smileFont.name
                font.pixelSize: 23
            }

            Row {
                width: parent.width

                spacing: 20
                padding: 5
                x: 15

                FluText {
                    text: qsTr("- CSilver 软件最小宽度 / 长度 [不建议小于默认数值]")
                    font.family: smileFont.name
                    font.pixelSize: 21
                }

                FluTextBox {
                    text: mainWindow.minimumWidth.toFixed(0)
                    font.pixelSize: 16
                    font.family: smileFont.name
                    width: 80
                    height: 30
                    y: -2
                    inputMethodHints: Qt.ImhDigitsOnly

                    onEditingFinished: {
                        let newValue = parseInt(text);
                        if (!isNaN(newValue) && newValue > 0 && newValue < mainWindow.maximumWidth) {
                            mainWindow.minimumWidth = newValue;
                        } else {
                            text = mainWindow.minimumWidth;
                        }
                    }

                    Keys.onReturnPressed: {
                        let newValue = parseInt(text);
                        if (!isNaN(newValue) && newValue > 0 && newValue < mainWindow.maximumWidth) {
                            mainWindow.minimumWidth = newValue;
                        } else {
                            text = mainWindow.minimumWidth;
                        }
                    }
                }

                FluText {
                    text: qsTr("X")
                    font.family: smileFont.name
                    font.pixelSize: 21
                }

                FluTextBox {
                    text: mainWindow.minimumHeight.toFixed(0)
                    font.pixelSize: 16
                    font.family: smileFont.name
                    width: 80
                    height: 30
                    y: -2
                    inputMethodHints: Qt.ImhDigitsOnly

                    onEditingFinished: {
                        let newValue = parseInt(text);
                        if (!isNaN(newValue) && newValue > 0 && newValue <= mainWindow.maximumHeight) {
                            mainWindow.minimumHeight = newValue;
                        } else {
                            text = mainWindow.minimumHeight;
                        }
                    }

                    Keys.onReturnPressed: {
                        let newValue = parseInt(text);
                        if (!isNaN(newValue) && newValue > 0 && newValue <= mainWindow.maximumHeight) {
                            mainWindow.minimumHeight = newValue;
                        } else {
                            text = mainWindow.minimumHeight;
                        }
                    }
                }
            }

            Row {
                width: parent.width

                spacing: 20
                padding: 5
                x: 15

                FluText {
                    text: qsTr("- 坐标轴 / 室内设定 颜色设置")
                    font.family: smileFont.name
                    font.pixelSize: 21
                }

                FluColorPicker{
                    width: 25
                    height: 25
                    onAccepted: {
                        mainWindow.colorBlue = current
                    }
                }
            }

            Row {
                width: parent.width

                spacing: 20
                padding: 5
                x: 15

                FluText {
                    text: qsTr("- 光源 颜色设置")
                    font.family: smileFont.name
                    font.pixelSize: 21
                }

                FluColorPicker{
                    width: 25
                    height: 25
                    onAccepted: {
                        mainWindow.colorGreen = current
                    }
                }
            }

            Row {
                width: parent.width

                spacing: 20
                padding: 5
                x: 15

                FluText {
                    text: qsTr("- 传感 颜色设置")
                    font.family: smileFont.name
                    font.pixelSize: 21
                }

                FluColorPicker{
                    width: 25
                    height: 25
                    onAccepted: {
                        mainWindow.colorPink = current
                    }
                }
            }
        }
    }
}
