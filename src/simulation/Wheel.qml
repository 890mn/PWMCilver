import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import FluentUI

Rectangle {
    id: wheel
    property int index
    property real centerX
    property real centerY

    width: 98
    height: 30
    radius: 8
    border.width: 4
    border.color: "#999"

    transform: Rotation {
        angle: 135 + index * 90
        origin.x: width / 2
        origin.y: height / 2
    }

    x: centerX + Math.cos((index * 90 + 45) * Math.PI / 180) * 130 - width / 2
    y: centerY + Math.sin((index * 90 + 45) * Math.PI / 180) * 130 - height / 2
}
