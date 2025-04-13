import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQuick.Shapes 1.15
import FluentUI

Rectangle {
    id: sensor
    property string direction: "front"

    width: direction === "left" || direction === "right" ? 8 : 70
    height: direction === "left" || direction === "right" ? 70 : 8

    color: "transparent"
    border.color: colorPinkHover
    border.width: 4
    z: 3
}

