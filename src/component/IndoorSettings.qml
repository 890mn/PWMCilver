import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import FluentUI
import "../canvas"

Rectangle {
    id: indoorSettings
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
        }
    }
}
